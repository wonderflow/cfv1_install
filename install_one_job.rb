$:.unshift File.dirname(__FILE__)
require 'autoinstall.rb'

ix = Install.new('opentsdb',0,'10.134.16.220','vcap','password')


ix.work
