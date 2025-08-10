# PetStore API
The developer must be able to programmatically manage pets at the pet store

## Successfully find a pet at the pet store

* Create a "findPetById" request for the "DefaultApi"
    * Give the "id" parameter a value of "1"
* Send the request
* The response status should be "200"

## I request to delete a pet from the pet store

* Create a "deletePet" request for the "DefaultApi"
    * Give the "id" parameter a value of "1"
* Send the request
* The response status should be "204"

## I request a list of all pets at the pet store with a matching tag

* Create a "findPets" request for the "DefaultApi"
    * Give the "tags" parameter the following values:
        | value |
        | cat   |
        | dog   |
    * Give the "limit" parameter a value of "2"
* Send the request
* The response status should be "200"

## I request a list of all pets at the pet store with a matching tag with no limit

* Create a "findPets" request for the "DefaultApi"
    * Give the "tags" parameter the following values:
        | value |
        | cat   |
        | dog   |
* Send the request
* The response status should be "200"

## I request to add a pet to the pet store
* Create an "addPet" request for the "DefaultApi"
    * Give the "petDetails" parameter a JSON value of "{\"name\": \"Pickle\", \"tag\": \"cat\"}"
* Send the request
* The response status should be "200"