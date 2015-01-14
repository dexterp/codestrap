Feature: Client uses remote codestraps and boilerplates
  In order to use remote codestraps and boilerplates
  as a user
  I want a client command that will support this functionality

  Scenario Outline: Use remote codestrap or boilerplate
    Given client tmp directory
    And client fixtures file "fixtures.yaml" with:
    """
    links: client/home/codestrap/bin
    codestrapfile: |
      Codestrapfile.config do |conf|
        conf.server.base = ['client/var/lib/codestrap']
        conf.local.base  = ['client/home/codestrap']
        conf.local.urls  = 'http://127.0.0.1:4567/rest/capability.json'
      end
    commands:
      stubbash:
        output: client/output/bashscript
        test:
          client/output/bashscript:
            local-data: 'true'
      strapgem:
        output: client/output/gem
        test:
          client/output/gem/template:
            local-data: 'true'
          client/output/gem/dir/template:
            local-data: 'true'
      stubbashremote:
        output: client/output/bashscriptremote
        test:
          client/output/bashscriptremote:
            remote-data: 'true'
      strapgemremote:
        output: client/output/gemremote
        test:
          client/output/gemremote/template:
            remote-data: 'true'
          client/output/gemremote/dir/template:
            remote-data: 'true'
      stubremote_local:
        output: client/output/file_remote_local
        test:
          client/output/file_remote_local:
            local-data: 'true'
      strapremote_local:
        output: client/output/dir_remote_local
        test:
          client/output/dir_remote_local/template:
            local-data: 'true'
          client/output/dir_remote_local/dir/template:
            local-data: 'true'
      stubremote_remote:
        output: client/output/file_remote_remote
        test:
          client/output/file_remote_remote:
            remote-data: 'true'
      strapremote_remote:
        output: client/output/dir_remote_remote
        test:
          client/output/dir_remote_remote/template:
            remote-data: 'true'
          client/output/dir_remote_remote/dir/template:
            remote-data: 'true'
      stublocal_remote:
        output: client/output/file_local_remote
        test:
          client/output/file_local_remote:
            remote-data: 'true'
      straplocal_remote:
        output: client/output/dir_local_remote
        test:
          client/output/dir_local_remote/template:
            remote-data: 'true'
          client/output/dir_local_remote/dir/template:
            remote-data: 'true'
      """
    And client fixture "<command>"
    And client generate command is called
    Then client runs "stub output"
    And client runs "strap output"
    And client stub exit code is 0
    And client strap exit code is 0
    And client stub has the correct interpolated values
    And client boilerplate has the correct interpolated values
  Examples:
    | command                |
    | stubbash          |
    | strapgem               |
    | stubbashremote    |
    | strapgemremote         |
    | stubremote_local  |
    | strapremote_local      |
    | stubremote_remote |
    | strapremote_remote     |
    | stublocal_remote  |
    | straplocal_remote      |

