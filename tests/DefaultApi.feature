Feature: PetStore API
    In order to programatically manage pets at the pet store
    As a developer
    I need to call pet store endpoints

Scenario: I request a list of all pets from the pet store
    Given there is a "FindPetById" request
    And the request has a parameter "id" with a value of "1"
    When the request is sent
    Then the response status is 200

Scenario: I request to delete a pet from the pet store
    Given there is a "DeletePet" request
    And the request has a parameter "id" with a value of "1"
    When the request is sent
    Then the response status is 204
