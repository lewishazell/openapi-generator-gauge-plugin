# Writing Gauge specs for `openapi-generator-gauge-plugin`

This guide explains how to write executable [Gauge specs](https://docs.gauge.org/writing-specifications.html) using the `openapi-generator-gauge-plugin`. The plugin wires OpenAPI-defined operations into structured test steps, allowing you to write human-readable specs to verify real API client behavior.

## Plugin overview

This plugin enables you to describe HTTP API client scenarios in BDT-custom syntax, and automatically executes them using code generated via [openapi-generator](https://github.com/OpenAPITools/openapi-generator)

You define the intended behavior of the API client and the Gauge steps will handle request construction, type coercion, response parsing and semantic comparisons.

## How Gauge specs map to OpenAPI specs

| Gauge Step Element           | Maps to OpenAPI Element                            |
|---------------------------------|----------------------------------------------------|
| API class (`PetApi`)            | The `tag` used in the OpenAPI operation definition |
| Operation ID (`findPetById`)    | The `operationId` in the OpenAPI operation object  |
| Parameters                      | Path, query, header, or body parameters            |
| Response status/content         | Defined responses for an operation                 |

### Example:

```yaml
paths:
  /pets/{id}:
    get:
      tags:
        - Pet
      operationId: findPetById
      parameters:
        - in: path
          name: id
          required: true
          schema:
            type: integer
```

In this case:

- The operation ID is `findPetById`
- The API class is `PetApi` (if tagged as "Pet") - or `DefaultApi` if untagged
- `id` is a required path parameter


### Naming normalization

Class names and operation IDs are normalized:

- API class names become **PascalCase**
- Operation IDs become **camelCase**

This ensures consistent naming across languages, as openapi-generator transforms identifiers.

## Supported steps

These are the officially supported Gauge steps. Steps must be written in the correct sequence for each request.

Required step order:

1. Create the request
1. Set parameters (optional)
1. Send the request
1. Assert response

Multiple request cycles are supported per scenario - just repeat the pattern.

### 1. Create a request

```
* Create a "findPetById" request for the "PetApi"
```

* `findPetById` is the `operationId`
* `PetApi` is the api class name, derved from `tags`

See your generated client code to confirm actual names.

### 2. Set parameter values

#### Simple value:

```
* Give the "id" parameter a value of "1"
```

#### JSON body value:

```
* Give the "petDetails" parameter a JSON value of:
    """
    { "name": "Pickle", "tag": "cat" }
    """
```

#### Multi-value array (e.g. query arrays:)

```
* Give the "tags" parameter the following values:
    | value |
    |-------|
    | cat   |
    | dog   |
```

### Type coercion

The plugin automatically coerces string values into the following types as defined by the schema:

- `int`, `float`, `double`, `boolean`
- `enum` values
- `UUID` / `GUID`

Type errors will be thrown if the string is in the incorrect format or coersion is not possible.

### 3. Send the Request

```
* Send the request
```

- Must come after setting parameters and before assertions.
- Internally, it executes the constructed request and stores the response for use in assertion steps.

### 4. Assert on the response

#### Status code:

```
* The response status should be "200"
```

#### Response body:

```
* The response content should be:
    """
    { "name": "Pickle", "tag": "cat", "id":1 }
    """
```

### Semantic JSON comparison

JSON content assertions use semantic equality, meaning:

- Property order doesn’t matter
- Whitespace is ignored
- Values must match in structure and content

#### Full-Body Matching:
```
* The response content should be:
    """
    { "name": "Pickle", "tag": "cat", "id": 1 }
    """
```

#### Partial Matching (subtree contains):
```
* The response content should contain the subtree:
    """
    { "name": "Pickle", "tag": "cat" }
    """
```

The **subtree contains** assertion checks if the expected subtree exists within the actual response, ignoring extra fields. This is useful for:
- Ignoring volatile fields (e.g., IDs, timestamps).
- Validating nested structures without requiring a full match.
- Asserting array contents (e.g., `[{ "name": "Pickle" }]`).

Therefore, this assertion passes:

```
* The response content should be:
    """
    { "name": "Pickle", "tag": "cat", "id":1 }
    """
```

even if the actual response is:

```json
{
  "id": 1,
  "tag": "cat",
  "name": "Pickle"
}
```

## Full example

```
# PetStore API
The developer must be able to programmatically manage pets at the pet store

## Successfully find a pet at the pet store
This scenario ensures that the user can successfully retrieve a pet from the store by its ID.

* Create a "findPetById" request for the "DefaultApi"
    * Give the "id" parameter a value of "1"
* Send the request
* The response status should be "200"
* The response content should be "{"name":"string","tag":"string","id":-9007199254740991}"
```

## Notes & limitations

| Behavior                | Notes                                                                                                |
|-------------------------|------------------------------------------------------------------------------------------------------|
| Multiple requests       | You can issue multiple requests in a scenario. Just follow the create “params” sequence for each.    |
| Step ordering           | Steps must follow the defined sequence. For example, assertions before sending a request will fail.  |
| Partial JSON matching   | In addition to full-body JSON comparisons, you can assert that the response contains a **JSON subtree** (a subset of fields or nested structures). This is useful for ignoring volatile fields like IDs or timestamps. See the "Assert on the Response" section for details. |
| API class name fallback | If an OpenAPI operation has no tags, it defaults to `DefaultApi`.                                    |

## Tips

- Use `tags` in your OpenAPI spec to control grouping and generate better API class names
- Always verify the normalized names used in generated step implementation code if you are unsure what to use in the spec
- Table parameters are ideal for arrays and repeated query parameters

## Related resources

- [Gauge Documentation](https://docs.gauge.org/)
- [OpenAPI Specification](https://swagger.io/specification/)
- [OpenAPI Generator](https://github.com/OpenAPITools/openapi-generator)