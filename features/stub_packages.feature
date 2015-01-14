Feature: Package management
  As a user, I will utilize a package, codestrap, modules manager for templates
  to download available packages from a package server(s).

  Scenario Outline: Package management
    Given test "<data>" set
    And environment variables
    When command "<command>" is executed
    And input
    Then a set of are created
    And output has the right contents and format
    And error has the right contents and format
    And exit code has expected values
  Examples:
    | data | command |
