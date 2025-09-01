#!/bin/bash

while [[ $# -gt 0 ]]; do
  case "$1" in
    --jar-file)
      JAR_FILE="$2"
      shift 2
      ;;
    --filter)
      FILTER="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: $0 [--jar-file path/to/jar] [--filter testname]"
      exit 0
      ;;
    *)
      shift
      ;;
  esac
done

oneTimeSetUp() {
    if [ "$JAR_FILE" = "" ]; then
        (cd .. && mvn clean package) || fail "Codegen plugin build failed"
        local version=$(cd .. && mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
        JAR_FILE="../target/openapi-generator-gauge-plugin-$version.jar"
    fi

    if [ ! -f "$JAR_FILE" ]; then
        echo "Error: JAR file not found at $JAR_FILE"
        exit 1
    fi

    echo "Using JAR: $JAR_FILE"

    prism mock petstore-extended.yaml &>/dev/null &
    PRISM_PID=$!
}

setUp() {
    mkdir -p out
    cp -r specs out
}

testCSharpCodegen() {
    filter "$FUNCNAME" || return 0

    local testdir="out/src/PetStore.Test"
    openapi-generator-cli --custom-generator "$JAR_FILE" generate -g csharp-gauge --package-name PetStore -i petstore-extended.yaml -o out -p gaugeTargetHost=http://localhost:4010
    mv "out/specs" "$testdir"
    (cd "$testdir" && gauge run specs)
    (cat "$testdir/reports/json-report/result.json" | scrubGaugeReport | verifyJson) || fail "Received report differed from verified snapshot"
}

testGoCodegen() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator "$JAR_FILE" generate -g go-gauge --package-name petstore -i petstore-extended.yaml -o out -p gaugeTargetHost=http://localhost:4010
    (cd out && go get -u -v all && gauge run specs)
    (cat "out/reports/json-report/result.json" | scrubGaugeReport | verifyJson) || fail "Received report differed from verified snapshot"
}

testJavaCodegenWithGradle() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator "$JAR_FILE" generate -g java-gauge --package-name PetStore -i petstore-extended.yaml -o out -p gaugeTargetHost=http://localhost:4010
    (cd out && gradle gauge)
    (cat "out/reports/json-report/result.json" | scrubGaugeReport | verifyJson) || fail "Received report differed from verified snapshot"
}

testJavaCodegenWithMaven() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator "$JAR_FILE" generate -g java-gauge --package-name PetStore -i petstore-extended.yaml -o out -p gaugeTargetHost=http://localhost:4010
    (cd out && mvn test-compile gauge:execute)
    (cat "out/reports/json-report/result.json" | scrubGaugeReport | verifyJson) || fail "Received report differed from verified snapshot"
}

testPythonCodegen() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator "$JAR_FILE" generate -g python-gauge --package-name petstore -i petstore-extended.yaml -o out -p gaugeTargetHost=http://localhost:4010
    (cd out && pip install -r requirements.txt -r test-requirements.txt && gauge run specs)
    (cat "out/reports/json-report/result.json" | scrubGaugeReport | verifyJson) || fail "Received report differed from verified snapshot"
}

testTypeScriptNodeCodegen() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator "$JAR_FILE" generate -g typescript-node-gauge -i petstore-extended.yaml -o out -p gaugeTargetHost=http://localhost:4010 -p npmName=petstore
    (cd out && npm install && gauge run specs)
    (cat "out/reports/json-report/result.json" | scrubGaugeReport | verifyJson) || fail "Received report differed from verified snapshot"
}

tearDown() {
    rm -r out
}

oneTimeTearDown() {
    [ -n "$PRISM_PID" ] && kill "$PRISM_PID" 2>/dev/null
}

filter() {
  local name=$1

  if [ "$FILTER" != "" ] && ! echo "$name" | grep -qi "$FILTER"; then
    echo "Skipping $name (filtered by FILTER=$FILTER)"
    return 1
  fi

  return 0
}

scrubGaugeReport() {
    cat | jq '
        del(.timestamp, .timestampISO, .executionTime) |
        .specResults |= map(
            del(.timestampISO, .executionTime, .fileName) |
            .scenarios |= map(
                del(.executionTime) |
                .items |= map(
                    .result |= del(.stackTrace, .executionTime, .screenshot, .ScreenshotFile, .errorMessage, .messages, .skippedReason)
                )
            )
        )
    '
}

verifyJson() {
    local snapshotpath="snapshots/${FUNCNAME[1]}.verified.json"
    local receivedpath="${snapshotpath/.verified.json/.received.json}"

    cat | tee "$receivedpath" | jd "$snapshotpath"
}

. /usr/share/shunit2/shunit2