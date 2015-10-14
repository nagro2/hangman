# Hangman game by Nick Agro
# This was created per assignment by the Odin Project
# Note the main objective was to utilize yaml file operations
# therefore some elements, such as parsing of input, are unsophisticated

require 'yaml'

class Game_operations
	def match_check(guess, not_guessed)
		if not_guessed.member?(guess)
			not_guessed -= [guess]
		end
		not_guessed
	end

	def show_currently_guessed(not_guessed, original)
		original.each do |letter|
			if not_guessed.member?(letter) || not_guessed.member?(letter.downcase)
				print "-"
			else 
				print letter
			end
		end
		print "\n"
	end

end

class File_operations
	def get_word
		words = File.readlines "5desk.txt"
		words = words.select {|line| (5..12) === line.chomp.length}
		words[rand(words.length)].chomp.split("")
	end

	def save_game(hidden_original, hidden_not_guessed, all_guesses)
		all_to_save = [hidden_original, hidden_not_guessed, all_guesses]
		f=File.open("save.yml", "w")
		f.write all_to_save.to_yaml
		f.close
		print "game saved.\n"
	end

	def restore_game
		begin
		  all=YAML.load(File.open("save.yml"))
		  all
		rescue
  		  puts "Could not restore game"
		  all=[ [], [], [] ]
		end
	end

end


class Game
	def interactive(restore)
		game_ops = Game_operations.new
		file_ops = File_operations.new
		hidden_original = file_ops.get_word

		if restore
			all = file_ops.restore_game
			if all[0] == []
				return
			end
			hidden_original = all[0]
			hidden_not_guessed = all[1]
			all_guesses = all[2]
			guess_count = all_guesses.length + 1
			print "your guesses so far: #{all_guesses}\n"
		else
			hidden_not_guessed = hidden_original.join.downcase.split("").uniq
			hidden_not_guessed -= [" "]

			guess_count=1
			guess=""
			all_guesses = []
		end

		print "Starting game. Press 'S' at any time to save game\n"
		game_ops.show_currently_guessed(hidden_not_guessed, hidden_original)

		while guess_count < 11 && hidden_not_guessed.length > 0 && guess != "S"
			print "enter your guess(#{guess_count}/10): "
			guess=gets.chomp

			all_guesses << guess

			hidden_not_guessed = game_ops.match_check(guess, hidden_not_guessed)
			game_ops.show_currently_guessed(hidden_not_guessed, hidden_original)

			guess_count +=1
		end


		if guess == "S"
			print "Saving game\n"
			file_ops.save_game(hidden_original, hidden_not_guessed, all_guesses)
		elsif hidden_not_guessed.length > 0
			print "sorry, you didn't win. The answer was: "
			game_ops.show_currently_guessed([], hidden_original)
			print "\n"
		else
			print "you won!\n"
		end
	end

end



puts "\n\n\nHangman game"

input =""
while input != "q"
	puts "select p for play, r for restore, q for quit:"
	input=gets.chomp

	if input=="p"
		game_now=Game.new
		game_now.interactive(false)
	elsif input == "r"
		print "restoring saved game...\n"
		game_now=Game.new
		game_now.interactive(true)
	end
end
print "exiting...\n\n"
