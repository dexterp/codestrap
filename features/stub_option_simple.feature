Feature: strap --help and --version
  Command supports the help and version options

  Scenario Outline: Simple options
    When the command "strap" with option "<simple_option>" is executed
    Then the option output is greater then 0 bytes
    And the option option exit status should be 0
  Examples: help
    | simple_option |
    | --help        |
    | -h            |
    | -?            |
    | -v            |
    | --version     |
