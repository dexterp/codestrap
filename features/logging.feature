Feature: Programing supports logging
  If an exception occurs in order to receive a meaningful message
  as a command line user
  the command needs to support adequate logging

  Scenario Outline: Logging
    Given logging tmp directory
    And logging fixtures file "fixtures.yaml" with:
    """
    links: logging/home/logging/codestrap/bin
    codestrapfile: |
      Codestrapfile.config do |conf|
        conf.local.base = [ 'logging/home/logging/codestrap' ]
        conf.local.urls = 'http://127.0.0.1:4567/rest/capability.json'
      end
    commands:
      codestrapcommand:
        output: logging/output/command
        output?: false
        stderr:
          - Could not find codestrap "command".
        exit: 255
      strapproject:
        output: logging/output/project
        output?: false
        stderr:
          - Could not find boilerplate "project".
        exit: 255
      codestrap --generate:
        output?: false
        stderr:
          - File "codestrapnotlink" is not a symlink.
          - File "codestrapdirectory" is not a symlink.
    """
    And logging fixture "<command>"
    And logging file linking
    When logging command is executed
    Then logging output may be generated
    And logging STDERR contains a message
    And logging exits
  Examples:
    | command         |
