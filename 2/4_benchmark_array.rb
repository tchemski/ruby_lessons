#!/usr/bin/ruby

1000000.times do
  vowels = %w(A E I O U)
  vowels_hash = {}
  counter = 0
  ('A'..'Z').each do |l|
    vowels_hash[l] = counter if vowels.include?(l)
    counter += 1
  end
end
