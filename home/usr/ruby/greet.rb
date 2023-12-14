#!/usr/bin/env ruby

class MegaGreeter

	# Using attr_accessor defines two new methods for us, name to get the value, and name= to set it.
	attr_accessor :names

	# Create the object
	def initialize(names = "World")

		@names = names

	end

	# Say hi to everybody
	def say_hi

		if @names.nil?

			puts "...but no one answered."

		elsif @names.respond_to?("each")

			# @names is a list of some kind, iterate!

			@names.each do |name|

				puts "Hello #{name}!"

			end

		else

			puts "Hello #{@names}!"

		end

	end

	# Say bye to everybody
	def say_bye

		if @names.nil?

			puts "...but nobody answered."

		# This method of not caring about the actual type of a variable, just
		# relying on what methods it supports is known as “Duck Typing”, as in
		# “if it walks like a duck and quacks like a duck...”
		elsif @names.respond_to?("join")

			# Join the list elements with commas

			puts "Goodbye #{@names.join(", ")}. Come back soon."

		else

			puts "Goodbye #{@names}. Come back soon."

		end

	end

end

# Here, __FILE__ is the magic variable that contains the name of the current
# file. $0 is the name of the file used to start the program. This check says
# “If this is the main file being used...” This allows a file to be used as a
# library, *and not to execute code in that context*, but if the file is being
# used as an executable, then execute that code.

# TLDR; If this is being used as a library, DON'T run this code.
if __FILE__ == $0

	# Instantiate new object
	mg = MegaGreeter.new

	# Say default greeting
	mg.say_hi
	mg.say_bye

	# Change name to be "Zeek"
	mg.names = "Zeek"
	mg.say_hi
	mg.say_bye

	# Change the name to be an array of names
	mg.names = ["Albert", "Brenda", "Charles III", "Dave", "Engelbert"]
	mg.say_hi
	mg.say_bye

	# Change to nil
	mg.names = nil
	mg.say_hi
	mg.say_bye

end



















