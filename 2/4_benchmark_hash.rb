#!/usr/bin/ruby

1000000.times do
  vowels_hash = {'A' => true,
                 'E' => true,
                 'I' => true,
                 'O' => true,
                 'U' => true}

  counter = 0
  ('A'..'Z').each do |l|
    vowels_hash[l] = counter if vowels_hash[l]
    counter += 1
  end
end
