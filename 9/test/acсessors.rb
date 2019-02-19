#!/usr/bin/ruby -w

require_relative '../accessors.rb'
require_relative '../validation.rb'

class Test
  extend Acсessors
  attr_accessor_with_history :a
  strong_attr_accessor x: Integer
end

t = Test.new

10.times { t.a = rand(10) }
p t.a
p t.a_history

begin
  print "Не даём присвоить Float to Integer"
  t.x = 0.0
  puts ' [ERROR!!!]'
rescue
  puts ' [OK]'
end

t.x = 8

puts 't.x = 8'
p t.x

puts "="*40
class TestValidation
  include Validation

  attr_accessor :name, :answer, :station
  validate :name, :presence
  validate :answer, :format, /^[yд]{1}|[nн]{1}$/i
  validate :station, :type, String
end

t = TestValidation.new

t.name, t.answer, t.station = "", "за", 12

puts 'проверяем...'
begin
  puts 't.name, t.answer, t.station = "", "за", 12'
  t.validate!
rescue Exception => e
  puts e.message
end

t.name = "hello"

begin
  puts 't.name = "hello"'
  t.validate!
rescue Exception => e
  puts e.message
end

t.answer = "Y"

begin
  puts 't.answer = "Y"'
  t.validate!
rescue Exception => e
  puts e.message
end

t.station = "Moscow"

begin
  puts 't.station = "Moscow"'
  t.validate!
  puts 'OK'
rescue Exception => e
  puts e.message
end
