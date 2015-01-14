Feature: Supports stubs
  As a user I want a command that supports file stubs
  of text files
  that contain interpolated objects

  Scenario Outline: stub creation
    Given a stub tmp directory
    And a stub fixtures file "fixtures.yaml" with:
    """
    stubaddress:
      clear: true
      links: stub/contact/home/user/dir/bin
      output: stub/contact/output/address
      codestrapfile: |
        Codestrapfile.config do |conf|
          conf.local.base = ['stub/contact/home/user/dir']
        end
      test:
        '10 Downing Street': true
    stubcell:
      clear: true
      links: stub/contact/home/user/dir/bin
      output: stub/contact/output/cell
      codestrapfile: |
        Codestrapfile.config do |conf|
          conf.local.base = ['stub/contact/home/user/dir']
        end
      test:
        '0555 5555 5555': true
    stubemail:
      clear: true
      links: stub/contact/home/user/dir/bin
      output: stub/contact/output/email
      codestrapfile: |
        Codestrapfile.config do |conf|
          conf.local.base = ['stub/contact/home/user/dir']
        end
      test:
        'dpgrps@gmail.com': true
    stubmobile:
      clear: true
      links: stub/contact/home/user/dir/bin
      output: stub/contact/output/mobile
      codestrapfile: |
        Codestrapfile.config do |conf|
          conf.local.base = ['stub/contact/home/user/dir']
        end
      test:
        '0444 4444 4444': true
    stubname:
      clear: true
      links: stub/contact/home/user/dir/bin
      output: stub/contact/output/name
      codestrapfile: |
        Codestrapfile.config do |conf|
          conf.local.base = ['stub/contact/home/user/dir']
        end
      test:
        'Full Name': true
    stubphone:
      clear: true
      links: stub/contact/home/user/dir/bin
      output: stub/contact/output/phone
      codestrapfile: |
        Codestrapfile.config do |conf|
          conf.local.base = ['stub/contact/home/user/dir']
        end
      test:
        '7777 7777': true
    stubyear:
      clear: true
      links: stub/date/home/user/stub/bin
      output: stub/date/output/year
      codestrapfile: |
        Codestrapfile.config do |conf|
          conf.local.base = ['stub/date/home/user/stub']
        end
      test: {}
    stubmonth:
      clear: true
      links: stub/date/home/user/stub/bin
      output: stub/date/output/month
      codestrapfile: |
        Codestrapfile.config do |conf|
          conf.local.base = ['stub/date/home/user/stub']
        end
      test: {}
    stubday:
      clear: true
      links: stub/date/home/user/stub/bin
      output: stub/date/output/day
      codestrapfile: |
        Codestrapfile.config do |conf|
          conf.local.base = ['stub/date/home/user/stub']
        end
      test: {}
    stubhour:
      clear: true
      links: stub/date/home/user/stub/bin
      output: stub/date/output/hour
      codestrapfile: |
        Codestrapfile.config do |conf|
          conf.local.base = ['stub/date/home/user/stub']
        end
      test: {}
    stubminute:
      clear: true
      links: stub/date/home/user/stub/bin
      output: stub/date/output/minute
      codestrapfile: |
        Codestrapfile.config do |conf|
          conf.local.base = ['stub/date/home/user/stub']
        end
      test: {}
    stubsecond:
      clear: true
      links: stub/date/home/user/stub/bin
      output: stub/date/output/second
      codestrapfile: |
        Codestrapfile.config do |conf|
          conf.local.base = ['stub/date/home/user/stub']
        end
      test: {}
    stubcredentials:
      clear: true
      links: stub/script/home/user/stub/bin
      output: stub/script/output/credentials
      codestrapfile: |
        Codestrapfile.config do |conf|
          conf.local.base = ['stub/script/home/user/stub']
        end
      test:
        'noreply@nodomain.com': true
        'secret': true
    """
    And a stub fixture "<command>"
    And stub env variable for PATH
    When generate
    And clear previous files
    And template is run with output
    Then contains interpolated values
    And the exit status is 0
  Examples:
    | command         |
    | stubaddress     |
    | stubcell        |
    | stubemail       |
    | stubmobile      |
    | stubname        |
    | stubphone       |
    | stubyear        |
    | stubmonth       |
    | stubday         |
    | stubhour        |
    | stubminute      |
    | stubsecond      |
    | stubcredentials |
