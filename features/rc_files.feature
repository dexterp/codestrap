Feature: Add "$HOME/.codestrap/bin" to PATH in $HOME/.profile or equavalent

  As a command line user
  I want to add $HOME/.codestrap/bin to PATH automatically
  So that I don't have to manually add an entry

  Scenario Outline: Add $HOME/.codestrap/bin to $PATH
    Given a known "<shell>"
    And a "<fake_home>" directory
    And with a ~/"<rcfile>"
    When the initialisation "strap -g" is run for rc_files more then once
    Then a path entry should be added. Once only
    Examples:
      | shell     | fake_home | rcfile        |
      | /bin/zsh  | zsh_home  | .zshrc        |
      | /bin/bash | bash_home | .bash_profile |
      | /bin/sh   | sh_home   | .profile      |