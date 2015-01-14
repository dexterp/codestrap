Feature: Remotely serve straps and stubs
  In order to serve stubs and straps remotely
  As a user
  I want a server that supports both types

  Scenario Outline: Serve a stub or strap
    Given server tmp directory
    And server fixtures file "fixtures.yaml" with:
    """
    - type: stub
      template: email
      codestrapfile: |
        Codestrapfile.config do |conf|
          conf.server.base = ['server/mixed/var/lib/stub']
          conf.local.urls = 'http://127.0.0.1:4567/rest/capability.json'
        end
    - type: strap
      template: puppetmodule
      codestrapfile: |
        Codestrapfile.config do |conf|
          conf.server.base = ['server/mixed/var/lib/stub']
          conf.local.urls = 'http://127.0.0.1:4567/rest/capability.json'
        end
    """
    And server fixture "<number>"
    And server capbility rest "/rest/capability.json" is valid
    And server object rest "/rest/objects.json" is valid
    And server stub metadata rest "/rest/stub/metadata.json" is valid
    And server strap metadata rest "/rest/strap/metadata.json" is valid
    And server list contains the correct keys
    Then server file should contain the correct content
    And server returns the right http code
  Examples:
    | number |
    | 0      |
    | 1      |
