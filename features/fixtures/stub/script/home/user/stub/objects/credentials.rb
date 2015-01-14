#!/usr/bin/env ruby

require 'json'

object = {
    'username' => 'username',
    'email'    => 'noreply@nodomain.com',
    'password' => 'secret',
}

print JSON.pretty_generate(object)
