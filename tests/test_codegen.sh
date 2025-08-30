#!/bin/bash

oneTimeSetUp() {
    (cd .. && mvn clean install) || fail "Codegen plugin build failed"
    prism mock petstore-extended.yaml &>/dev/null &
    PRISM_PID=$!
}

setUp() {
    mkdir -p out
    cp -r specs out
}

testCSharpCodegen() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator ../target/openapi-generator-gauge-plugin-1.0.0.jar generate -g csharp-gauge --package-name PetStore -i petstore-extended.yaml -o out -p gaugeTargetHost=http://localhost:4010
    mv out/specs out/src/PetStore.Test
    (cd out/src/PetStore.Test && gauge run specs) || fail "Gauge run failed"
}

testGoCodegen() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator ../target/openapi-generator-gauge-plugin-1.0.0.jar generate -g go-gauge --package-name petstore -i petstore-extended.yaml -o out -p gaugeTargetHost=http://localhost:4010
    (cd out && go get -u -v all && gauge run specs) || fail "Gauge run failed"
}

testJavaCodegenWithGradle() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator ../target/openapi-generator-gauge-plugin-1.0.0.jar generate -g java-gauge --package-name PetStore -i petstore-extended.yaml -o out -p gaugeTargetHost=http://localhost:4010
    (cd out && gradle gauge) || fail "Gauge run failed"
}

testJavaCodegenWithMaven() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator ../target/openapi-generator-gauge-plugin-1.0.0.jar generate -g java-gauge --package-name PetStore -i petstore-extended.yaml -o out -p gaugeTargetHost=http://localhost:4010
    (cd out && mvn test-compile gauge:execute) || fail "Gauge run failed"
}

testPythonCodegen() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator ../target/openapi-generator-gauge-plugin-1.0.0.jar generate -g python-gauge --package-name petstore -i petstore-extended.yaml -o out -p gaugeTargetHost=http://localhost:4010
    (cd out && gauge run specs) || fail "Gauge run failed"
}

testTypeScriptNodeCodegen() {
    filter "$FUNCNAME" || return 0

    openapi-generator-cli --custom-generator ../target/openapi-generator-gauge-plugin-1.0.0.jar generate -g typescript-node-gauge -i petstore-extended.yaml -o out -p gaugeTargetHost=http://localhost:4010 -p npmName=petstore
    (cd out && npm install && gauge run specs) || fail "Gauge run failed"
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

. /usr/share/shunit2/shunit2