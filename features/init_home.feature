Feature: $HOME/.codestrap directory initialisation

As a command line user
I want to initialise a skeleton $HOME/.codestrap directory
So that I the user does not have to manually create

  Scenario: Initialisation
    Given a missing ~/.codestrap directory
    When the initialisation "strap -g" is run
    Then the ~/.codestrap/bin directory is created
    And the ~/.codestrap/content directory is created
    And the ~/.codestrap/objects directory is created
    And the ~/.codestrap/Codestrail file is created


