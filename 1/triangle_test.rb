#!/usr/bin/ruby

# Прямоугольный треугольник. Программа запрашивает у пользователя 3 стороны треугольника и
# определяет, является ли треугольник прямоугольным, используя теорему Пифагора (www-formula.ru)
# и выводит результат на экран. Также, если треугольник является при этом равнобедренным
# (т.е. у него равны любые 2 стороны), то дополнительно выводится информация о том, что
# треугольник еще и равнобедренный. Подсказка: чтобы воспользоваться теоремой Пифагора, нужно
# сначала найти самую длинную сторону (гипотенуза) и сравнить ее значение в квадрате с суммой
# квадратов двух остальных сторон. Если все 3 стороны равны, то треугольник равнобедренный и
# равносторонний, но не прямоугольный.

unless ARGV.size == 3
  puts "Пример: triangle_test.rb 3 4 5"
  exit
end

sides = ARGV.map{|s| s.to_f}.sort

# так как стороны отсортированы, достаточно смотреть две последовательные пары
n = [ sides[0] == sides[1],
      sides[1] == sides[2] ].count{|e| e}

answers = []

if n == 1
  answers.push "равнобедренный"
elsif n == 2
  answers.push "равносторонний"
end

if sides[2]**2 == sides[0]**2 + sides[1]**2
  answers.push "прямоугольный"
else
  answers.push "непрямоугольный"
end

puts "Треугольник #{answers.join(' и ')}."