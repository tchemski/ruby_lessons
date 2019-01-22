#!/usr/bin/ruby -w

# Заполнить хеш гласными буквами, где значением будет являтся порядковый номер буквы в алфавите

vowels = %w(A E I O U)
vowels_hash = {}

vowels.each{|l| vowels_hash[l] = true}

counter = 0
('A'..'Z').each do |l|
  vowels_hash[l] = counter if vowels_hash[l]
  counter += 1
end

p vowels_hash
