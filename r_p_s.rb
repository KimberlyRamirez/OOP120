class Move
  attr_reader :value

  def initialize(value)
    @value = value
  end

  VALUES = ["rock", "paper", "scissor", "spock", "lizard"]

  def abbrev_to_full
    return value if value.size > 2

    case value
    when "r" then "rock"
    when "p" then "paper"
    when "sc" then "scissor"
    when "sp" then "spock"
    when "l" then "lizard"
    end
  end

  def >(other_move)
    value = abbrev_to_full
    other_move = other_move.to_s

    case value
    when "rock" then Rock.winning_moves(other_move)
    when "scissor" then Scissor.winning_moves(other_move)
    when "paper" then Paper.winning_moves(other_move)
    when "spock" then Spock.winning_moves(other_move)
    when "lizard" then Lizard.winning_moves(other_move)
    end
  end

  def <(other_move)
    value = abbrev_to_full
    other_move = other_move.to_s

    case other_move
    when "rock" then Rock.winning_moves(value)
    when "scissor" then Scissor.winning_moves(value)
    when "paper" then Paper.winning_moves(value)
    when "spock" then Spock.winning_moves(value)
    when "lizard" then Lizard.winning_moves(value)
    end
  end

  def to_s
    value
  end
end

class Rock
  def self.winning_moves(move)
    ["scissor", "lizard"].include?(move)
  end
end

class Paper
  def self.winning_moves(move)
    ["rock", "spock"].include?(move)
  end
end

class Scissor
  def self.winning_moves(move)
    ["lizard", "paper"].include?(move)
  end
end

class Spock
  def self.winning_moves(move)
    ["rock", "scissor"].include?(move)
  end
end

class Lizard
  def self.winning_moves(move)
    ["spock", "paper"].include?(move)
  end
end

class Player
  attr_accessor :move, :name

  def initialize
    set_name
  end
end

class Human < Player
  def set_name
    n = ""
    loop do
      puts "What's your name?"
      n = gets.chomp.strip
      break unless n.empty?
      puts "Sorry you must enter a value"
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock(r), paper(p), scissor(sc), spock(sp), lizard(l):"
      choice = gets.chomp.downcase.strip
      break if valid?(choice)
      puts "Sorry, invalid"
    end
    self.move = Move.new(choice)
  end

  def valid?(choice)
    (%w(r p sc sp l)).include?(choice) || Move::VALUES.include?(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ["R2D2", "Eva", "C3PO", "Wall-E"].sample
  end

  def eva_personality
    %w(rock rock spock spock scissor scissor)
  end

  def r2d2_personality
    %w(rock spock spock spock scissor scissor paper lizard)
  end

  def walle_personality
    %w(paper paper paper lizard)
  end

  def c3po_personality
    %w(rock paper scissor)
  end

  def choose
    case name
    when "Eva" then self.move = Move.new(eva_personality.sample)
    when "R2D2" then self.move = Move.new(r2d2_personality.sample)
    when "C3PO" then self.move = Move.new(c3po_personality.sample)
    when "Wall-E" then self.move = Move.new(walle_personality.sample)
    end
  end
end

class RPSGame
  attr_accessor :human, :computer, :round, :score

  def initialize
    system_clear
    @human = Human.new
    @computer = Computer.new
    @player_history = []
    @computer_history = []
    @score = { player: 0, computer: 0 }
    @round = 1
  end

  def system_clear
    system "clear"
  end

  def winning_moves_display
    puts <<~HEREDOC
    *-----------------------------------------------*
    Rock(r) - Crushes Lizard - Crushes Scissor
    Paper(p) - Disproves Spock - Paper Covers Rock
    Scissors(sc) - Decapitates Lizard - Cuts Paper
    Spock(sp) - Vaporizes Rock - Smashes Scissor
    Lizard(l) - Eats Paper - Posions Spock
    *------------------------------------------------*
    HEREDOC
  end

  def ready_for_game
    puts "When you are ready to start the game, press the enter button"
    answer = gets.chomp
    sleep until answer
    system_clear
  end

  def display_welcome_message
    system_clear
    puts <<~HEREDOC
    Hi #{human.name}! Welcome to Rock, Paper, Scissor, Spock, Lizard!

    You will be playing against a randomly selected robot! Each round
    you will need to pick a move from the list below. The round winner
    will get one point. Whoever gets to 10 points first, wins the game
    and claims VICTORY!! May the odds be ever in your favor!!

    HEREDOC
    winning_moves_display

    ready_for_game
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissor, Spock, Lizard. Good bye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move.abbrev_to_full}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def display_scoreboard
    # I am disabling this. It fits on the screen, it just has long names
    # rubocop:disable Layout/LineLength:
    puts "Round #{@round} Scoreboard: #{human.name} => #{@score[:player]} #{computer.name} => #{@score[:computer]}"
    # rubocop:enable Layout/LineLength:
  end

  def round_winner
    if human.move > computer.move
      @score[:player] += 1

      puts "*** #{human.name} won this round! ***"
    elsif human.move < computer.move
      @score[:computer] += 1
      puts "*** #{computer.name} won this round! ***"
    else
      puts "*** It's a tie! ***"
    end
  end

  def save_moves
    @player_history << @human.move.abbrev_to_full
    @computer_history << @computer.move.abbrev_to_full
    divider
  end

  def player_history_display
    loop do
      puts "Do you want to see your move history?"
      answer = gets.chomp.strip

      case answer
      when "yes", "y" then break puts @player_history.join(", ")
      when "no", "n" then break
      else
        puts "Sorry you must enter y, or n"
      end
    end
  end

  def computer_history_display
    loop do
      puts "Do you want to see the computer's history?"
      answer = gets.chomp.strip

      case answer
      when "yes", "y" then break puts @computer_history.join(", ")
      when "no", "n" then break
      else
        puts "Sorry you must enter y, or n"
      end
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ["y", "n"].include?(answer)
      puts "Sorry, must be y or n"
    end
    return false if answer.downcase == "n"
    return true if answer.downcase == "y"
  end

  def grand_winner
    if @score[:player] == 10 && @score[:computer] == 10
      false
    elsif @score[:player] >= 10 || @score[:computer] >= 10
      true
    else
      false
    end
  end

  def display_grand_winner
    if @score[:player] == 10
      puts "#{human.name} won the game!!!"
    else
      puts "I hate to tell you this; you lost the game!"
    end
  end

  def reset
    @score = { player: 0, computer: 0 }
    @round = 1
    system_clear
  end

  def divider
    puts "----------------------------------------------------"
  end

  def ready_for_next_round
    divider
    puts "When you are ready for the next round hit the enter key"
    divider
    answer = gets.chomp
    sleep until answer
    system_clear
  end

  def make_choice
    human.choose
    computer.choose
  end

  def play_round
    display_scoreboard
    make_choice
    display_moves
    save_moves
    round_winner
    ready_for_next_round
    @round += 1
  end

  def play
    display_welcome_message
    loop do
      play_round until grand_winner == true
      display_grand_winner
      player_history_display
      computer_history_display
      break unless play_again?
      reset
    end

    display_goodbye_message
  end
end

RPSGame.new.play
