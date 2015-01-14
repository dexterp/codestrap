Feature: Supports straps
  As a user I want a command that supports creation
  of a software project structure containing template output
  that has interpolated objects

  Scenario Outline: create a new project
    Given a boilerplate path directory "strap/projects/home/user/dir/bin"
    And a boilerplate fixture <number>
    And a boilerplate tmp directory
    And a boilerplate codestrapfile named "Codestrapfile" with:
    """
    Codestrapfile.config do |conf|
      conf.local.base = ['strap/projects/home/user/dir']
    end
    """
    And a boilerplate fixtures file named "fixtures.yaml" with:
    """
    ---
    - clear: 'true'
      command: strappuppetmodule
      output: strap/projects/output/newpuppet
      test:
        strap/projects/output/newpuppet/Modulefile:
          Michonne: 'true'
        strap/projects/output/newpuppet/manifests/init.pp:
          Michonne: 'true'
          dpgrps@gmail.com: 'true'
    """
    When boilerplate generate command is executed
    And boilerplate command is run
    Then boilerplate contains interpolated values
  Examples:
    | number |
    | 0      |
