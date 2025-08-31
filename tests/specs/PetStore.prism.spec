# PetStore API
The developer must be able to programmatically manage pets at the pet store

## Successfully find a pet at the pet store
This scenario ensures that the user can successfully retrieve a pet from the store by its ID.

* Create a "findPetById" request for the "DefaultApi"
    * Give the "id" parameter a value of "1"
* Send the request
* The response status should be "200"
* The response content should be "{\"name\":\"string\",\"tag\":\"string\",\"id\":-9007199254740991}"

## Successfully find a pet at the pet store with an incorrect response status
This scenario ensures that the user can successfully retrieve a pet from the store by its ID, but asserts an incorrect response status.

* Create a "findPetById" request for the "DefaultApi"
    * Give the "id" parameter a value of "1"
* Send the request
* The response status should be "201"
* The response content should be "{\"name\":\"string\",\"tag\":\"string\",\"id\":-9007199254740991}"

## Successfully find a pet at the pet store with an incorrect response content
This scenario ensures that the user can successfully retrieve a pet from the store by its ID, but asserts an incorrect response content.

* Create a "findPetById" request for the "DefaultApi"
    * Give the "id" parameter a value of "1"
* Send the request
* The response status should be "200"
* The response content should be "{\"name\":\"Pickle\",\"tag\":\"cat\",\"id\":1}"

## Successfully delete a pet from the pet store
This scenario verifies that a pet can be deleted successfully from the pet store using its ID.

* Create a "deletePet" request for the "DefaultApi"
    * Give the "id" parameter a value of "1"
* Send the request
* The response status should be "204"

## Successfully list all pets at the pet store with a matching tag
This scenario checks that the user can list pets at the pet store that match specified tags.

* Create a "findPets" request for the "DefaultApi"
    * Give the "tags" parameter the following values:
        | value |
        |-------|
        | cat   |
        | dog   |
    * Give the "limit" parameter a value of "2"
* Send the request
* The response status should be "200"
* The response content should be "[{\"name\":\"string\",\"tag\":\"string\",\"id\":-9007199254740991}]"

## Successfully list all pets at the pet store with a matching tag with no limit
This scenario tests the ability to list all pets matching specified tags, but without any limits on the number of results.

* Create a "findPets" request for the "DefaultApi"
    * Give the "tags" parameter the following values:
        | value |
        |-------|
        | cat   |
        | dog   |
* Send the request
* The response status should be "200"

## Successfully add a pet to the pet store
This scenario ensures that a pet can be successfully added to the pet store.

* Create an "addPet" request for the "DefaultApi"
    * Give the "petDetails" parameter a JSON value of "{\"name\": \"Pickle\", \"tag\": \"cat\"}"
* Send the request
* The response status should be "200"