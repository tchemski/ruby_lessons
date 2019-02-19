#!/usr/bin/ruby -w

require_relative '../menu.rb'

# test # test # test # test # test # test # test # test # test # test # test
if $PROGRAM_NAME == __FILE__
  sub_menu = Menu.new(
    { 'item1' => proc { puts 'item1 selected' },
      'item2' => proc { puts 'item2 selected' } },
    'Sub menu'
  ).get_proc

  menu = Menu.new(
    'item1' => proc { puts 'item1 selected' },
    'item2' => proc { puts 'item2 selected' },
    'item3' => proc { puts 'item3 selected' },
    'sub menu' => sub_menu
  ).get_proc

  menu.call

  a = %w[a b c d e]
  puts a[Menu.get_array_id(a)]
end
