#!/usr/bin/env ruby

class Person

	attr_accessor :name, :age

	def initialize(name, age)

		@name = name
		@age = age.to_i

	end

	def inspect

		# (For internal use)
		"#{name} (#{age})"

		# (For printing to console)
		# puts "#{name} (#{age})"

	end

end

people = Array.new

# todo this is a good place to start testing pathname objects

# todo does ruby have any modules specifically for reading INI files?

# Read each line of a file as an object, and use a single array to point to
# all of these line objects - voila! Array methods for dealing with the
# contents of a text file.
File.foreach("ages") do |line|

	people << Person.new($1, $2) if line =~ /(.*):\s+(\d+)/

end

puts "#{people}"

sorted = people.sort {|a, b| a.age <=> b.age}

puts "#{sorted}"
