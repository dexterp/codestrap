Feature: Supports script object creation
  The command supports objects created from JSON. The objects
  can be used in the template.

  Scenario Outline: creating a script object
    Given a script directory "<dir>"
    And a script "<script>"
    When a script run to create an object
    Then the objects JSON syntax is valid
    And a object is created
  Examples:
    | dir                                                  | script         |
    | features/fixtures/stub/script/home/user/stub/objects | credentials.rb |