#!/usr/local/bin/ruby
require File.dirname(__FILE__) + "/../config/environment"
require_gem 'fcgi'
require 'fcgi_handler'

RailsFCGIHandler.process! nil, 50

