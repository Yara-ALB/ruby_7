# variable count instead of the hangman drawing (10 rounds)
# game:
  # display all the letters, the word chosen by computer in "_ _ _ _ _ _" and the number of guess
  # player choose a letter:
    # if the letter is in the word --> display it on the right place
    # else, count ++
    # put the letter in variable letters_used

  # if player types letter already used, puts "letter already used, type another one"
  # if player types other that letters, puts "type a letter displayed above"

  # if count == 10 --> player loses
  # elsif player guessed all the letters --> win when all the "_ _ _ _ _ _" are replaced by the correct letters
  # else, continue the game until win or lose

require 'yaml'

class Game
  def initialize(saved_data = nil)
    if saved_data
      @secret_word = saved_data[:secret_word]
      @guess_letters = saved_data[:guess_letters]
      @count = saved_data[:count]
    else
      words = File.readlines("google-10000-english-no-swears.txt", chomp: true)
      words_to_use = words.select { |word| word.length.between?(5, 12) }
      @secret_word = words_to_use.sample.upcase
      @guess_letters = []
      @count = 0
    end
  end

  def display_guessword()
    puts "\n"
    alphabet = ("A".."Z").to_a
    remaining = alphabet - @guess_letters
    puts remaining.join(", ")

    puts "\n"
    secret_letters = @secret_word.chars
    display_letters = secret_letters.map do |letter|
      if @guess_letters.include?(letter)
        letter
      else
        "_"
      end
    end
    display_word = display_letters.join(" ")
    puts display_word
  end

  def get_guess()
    player_input = nil

    loop do
      puts "\n"
      puts "Type a letter (or 'SV' to save your progress)"
      player_input = gets.chomp.upcase

      if player_input == "SV"
        break
      elsif player_input.length == 1 && player_input.match?(/[A-Z]/) && !@guess_letters.include?(player_input)
        @guess_letters << player_input
        break
      elsif player_input.length != 1
        puts "Please use a single letter"
      elsif !player_input.match?(/[A-Z]/)
        puts "Please type only letters"
      elsif @guess_letters.include?(player_input)
        puts "Please type a non used letter"
      end
    end

    player_input
  end

  def check_guess(letter)
    if @secret_word.include?(letter)
      puts "\n"
      puts "Correct!"
    else
      @count += 1
      puts "\n"
      puts "Wrong..."
      puts "#{@count}/10 chances used"
    end
  end

  def play_game()
    loop do
      display_guessword()
      letter = get_guess()

      if letter == "SV"
        data = save_data()
        File.write("savefile.yml", data.to_yaml)
        puts "Game saved!"
        break
      end

      check_guess(letter)

      if @count == 10
        puts "You lose... The word was #{@secret_word}"
        break
      elsif @secret_word.chars.uniq.all?{|secret_letter| @guess_letters.include?(secret_letter)}
        puts "You win! Congrats! The word was #{@secret_word}"
        break
      end
    end
  end

  def save_data
    {secret_word: @secret_word, guess_letters: @guess_letters, count: @count }
  end

  def self.load_from_file(filename)
    text = File.read(filename)
    YAML.load(text)
  end
end


puts "New game or load saved game? (type 'n' or 'l')"
choice = gets.chomp.downcase

if choice == "l" && File.exist?("savefile.yml")
  loaded_hash = Game.load_from_file("savefile.yml")
  game = Game.new(loaded_hash)
else
  game = Game.new
end

game.play_game()
