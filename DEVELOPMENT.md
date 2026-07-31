# OpenAPI Generator Gauge Plugin - development guide

## Overview

This plugin generates Gauge step implementations for OpenAPI specifications, enabling BDD testing of REST APIs. It supports:

- **Languages**: TypeScript, Python, Java, Go, C#
- **Features**:
  - JSON Path chaining (`* the "id" parameter is "$.id" from the previous response`)
  - Request/response validation
  - File uploads
  - Authentication (API keys, access tokens)

## Setup

### Prerequisites

- Java 11+
- Maven 3.6+
- Node.js (for TypeScript tests)
- Python 3.7+ (for Python tests)
- Go 1.16+ (for Go tests)
- .NET 6+ (for C# tests)

### Build the plugin

```bash
mvn clean package
```

This generates `target/openapi-generator-gauge-plugin-1.0.0-SNAPSHOT.jar`.

## Running tests

### Execute all tests

```bash
cd tests
./test_codegen.sh
./test_auth.sh
```

### Update snapshots

If test output changes (e.g., after modifying step implementations), update snapshots:
```bash
cd tests
./update_snapshots.sh
```

### Test-specific commands

- **TypeScript**: `npm install && gauge run specs` (in `tests/out/`)
- **Python**: `pip install -r requirements.txt -r test-requirements.txt && gauge run specs` (in `tests/out/`)
- **Java (Gradle)**: `gradle gauge` (in `tests/out/`)
- **Java (Maven)**: `mvn test-compile gauge:execute` (in `tests/out/`)
- **Go**: `go get -u -v all && gauge run specs` (in `tests/out/`)
- **C#**: `gauge run specs` (in `tests/out/src/PetStore.Test/`)

## Adding new step implementations

### 1. Define the Step in Spec Files

Add the step to `tests/specs/PetStore.prism.spec` (or other mock spec files). Example:

```markdown
* the "id" parameter is "$.id" from the previous response
```

### 2. Implement the step in mustache templates

Edit the language-specific template in `src/main/resources/<language>-gauge/gauge_steps.mustache`. Example for Java:

```java
@Step("the <parameter> parameter is <jsonPath> from the previous response")
public void giveTheParameterIsFromPreviousResponse(String parameter, String jsonPath) {
    if (previousResponse == null) {
        throw new IllegalStateException("No previous response exists.");
    }
    // ... implementation
}
```

### 3. Add dependencies (if needed)

Update the language-specific dependency file (e.g., `pom.mustache` for Java, `package.mustache` for TypeScript).

### 4. Test the implementation

1. Build the plugin (`mvn clean package`).
2. Run tests (`./tests/test_codegen.sh`).
3. Update snapshots if needed (`./tests/update_snapshots.sh`).

## Key directories

| Directory | Purpose |
|-----------|---------|
| `src/main/java` | Plugin code (Java). |
| `src/main/resources` | Mustache templates for code generation. |
| `tests/` | Test suite and mock OpenAPI specs. |
| `tests/specs/` | Gauge spec files. |
| `tests/mocks/` | Mock APIs. |
| `tests/snapshots/` | Expected test output (for comparison). |

## JSON path chaining

### How it works

1. **State management**: Previous responses are stored in `previousResponse` (Java/C#/TypeScript), `PreviousBody` (Go), or `previous_response` (Python).
2. **Error handling**: Steps fail if:
   - No previous response exists.
   - Previous response is not JSON.
   - JSON Path query returns no results.
3. **Libraries**:
   - TypeScript: `jsonpath-plus`
   - Python: `jsonpath-ng`
   - Java: `com.jayway.jsonpath:json-path`
   - Go: `github.com/PaesslerAG/jsonpath`
   - C#: `JsonPath.Net`

### Example

```markdown
## Chain JSON response data to request parameters using JSON Path
This scenario verifies that a value from a previous response can be chained to a subsequent request using JSON Path.

* Create an "addPet" request for the "DefaultApi"
    * Give the "PetDetails" parameter a JSON value of "{\"name\": \"Pickle\", \"tag\": \"cat\"}"
* Send the request
* The response status should be "200"

* Create a "findPetById" request for the "DefaultApi"
    * the "id" parameter is "$.id" from the previous response
* Send the request
* The response status should be "200"
```

## Troubleshooting

### Common issues

1. **Snapshot mismatches**:
   - Run `./tests/update_snapshots.sh` to regenerate snapshots.
2. **Missing dependencies**:
   - Ensure all language-specific dependencies are installed (e.g., `npm install`, `pip install -r requirements.txt`).
3. **Prism mock API**:
   - Prism returns placeholder values (e.g., `"name":"string"`). Tests must account for this.

### Debugging tests

- **Java**: Run `gradle gauge --info` or `mvn test-compile gauge:execute` with debug flags.
- **Python**: Run `gauge run specs --verbose` for verbose output.
- **TypeScript**: Run `gauge run specs --verbose`.

## Releasing

1. Update the version in `pom.xml`.
2. Build the plugin (`mvn clean package`).
3. Deploy to Maven Central or a local repository.

## Contributing

1. Fork the repository.
2. Create a feature branch.
3. Implement changes and add tests.
4. Update snapshots if needed.
5. Submit a PR.