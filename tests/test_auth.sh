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

    (cd mocks/earth && npm install)

    node mocks/earth/app.js &>/dev/null &
    EARTH_PID=$!
}

setUp() {
    mkdir -p out
    cp -r mocks/earth/specs out
}

testCSharpAccessTokenAuth() {
    filter "$FUNCNAME" || return 0

    local testdir="out/src/Earth.Test"
    openapi-generator-cli --custom-generator "$JAR_FILE" generate -g csharp-gauge --package-name Earth -i mocks/earth/openapi.yaml -o out -p gaugeTargetHost=http://localhost:3000
    mv "out/specs" "$testdir"
    (cd "$testdir" && gauge_access_token="valid-token" gauge run specs)

    (cat "$testdir/reports/json-report/result.json" | scrubGaugeReport | verifyJson) || fail "Received report differed from verified snapshot"
}

testCSharpApiKeyAuth() {
    filter "$FUNCNAME" || return 0

    local testdir="out/src/Earth.Test"
    openapi-generator-cli --custom-generator "$JAR_FILE" generate -g csharp-gauge --package-name Earth -i mocks/earth/openapi.yaml -o out -p gaugeTargetHost=http://localhost:3000
    mv "out/specs" "$testdir"
    (cd "$testdir" && gauge_api_key="valid-api-key" gauge_security_scheme="x-api-key" gauge run specs)

    (cat "$testdir/reports/json-report/result.json" | scrubGaugeReport | verifyJson) || fail "Received report differed from verified snapshot"
}

testGoAccessTokenAuth() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator "$JAR_FILE" generate -g go-gauge --package-name earth -i mocks/earth/openapi.yaml -o out -p gaugeTargetHost=http://localhost:3000
    (cd out && go get -u -v all && gauge_access_token="valid-token" gauge run specs)
    (cat "out/reports/json-report/result.json" | scrubGaugeReport | verifyJson) || fail "Received report differed from verified snapshot"
}

testGoApiKeyAuth() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator "$JAR_FILE" generate -g go-gauge --package-name earth -i mocks/earth/openapi.yaml -o out -p gaugeTargetHost=http://localhost:3000
    (cd out && go get -u -v all && gauge_api_key="valid-api-key" gauge_security_scheme="ApiKeyAuth" gauge run specs)
    (cat "out/reports/json-report/result.json" | scrubGaugeReport | verifyJson) || fail "Received report differed from verified snapshot"
}

testJavaAccessTokenAuth() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator "$JAR_FILE" generate -g java-gauge --package-name Earth -i mocks/earth/openapi.yaml -o out -p gaugeTargetHost=http://localhost:3000
    (cd out && gauge_access_token="valid-token" gradle gauge)
    (cat "out/reports/json-report/result.json" | scrubGaugeReport | verifyJson) || fail "Received report differed from verified snapshot"
}

testJavaApiKeyAuth() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator "$JAR_FILE" generate -g java-gauge --package-name Earth -i mocks/earth/openapi.yaml -o out -p gaugeTargetHost=http://localhost:3000
    (cd out && gauge_api_key="valid-api-key" gauge_security_scheme="ApiKeyAuth" gradle gauge)
    (cat "out/reports/json-report/result.json" | scrubGaugeReport | verifyJson) || fail "Received report differed from verified snapshot"
}

testPythonAccessTokenAuth() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator "$JAR_FILE" generate -g python-gauge --package-name earth -i mocks/earth/openapi.yaml -o out -p gaugeTargetHost=http://localhost:3000
    (cd out && pip install -r requirements.txt -r test-requirements.txt && gauge_access_token="valid-token" gauge run specs)
    (cat "out/reports/json-report/result.json" | scrubGaugeReport | verifyJson) || fail "Received report differed from verified snapshot"
}

testPythonApiKeyAuth() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator "$JAR_FILE" generate -g python-gauge --package-name earth -i mocks/earth/openapi.yaml -o out -p gaugeTargetHost=http://localhost:3000
    (cd out && pip install -r requirements.txt -r test-requirements.txt && gauge_api_key="valid-api-key" gauge_security_scheme="ApiKeyAuth" gauge run specs)
    (cat "out/reports/json-report/result.json" | scrubGaugeReport | verifyJson) || fail "Received report differed from verified snapshot"
}

testTypeScriptNodeAccessTokenAuth() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator "$JAR_FILE" generate -g typescript-node-gauge -i mocks/earth/openapi.yaml -o out -p gaugeTargetHost=http://localhost:3000 -p npmName=earth
    (cd out && npm install && gauge_access_token="valid-token" gauge run specs)
    (cat "out/reports/json-report/result.json" | scrubGaugeReport | verifyJson) || fail "Received report differed from verified snapshot"
}

testTypeScriptNodeApiKeyAuth() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator "$JAR_FILE" generate -g typescript-node-gauge -i mocks/earth/openapi.yaml -o out -p gaugeTargetHost=http://localhost:3000 -p npmName=earth
    (cd out && npm install && gauge_api_key="valid-api-key" gauge_security_scheme="ApiKeyAuth" gauge run specs)
    (cat "out/reports/json-report/result.json" | scrubGaugeReport | verifyJson) || fail "Received report differed from verified snapshot"
}

tearDown() {
    rm -r out
}

oneTimeTearDown() {
    [ -n "$EARTH_PID" ] && kill "$EARTH_PID" 2>/dev/null
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