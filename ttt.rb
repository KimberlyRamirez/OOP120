class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def find_at_risk_square(marker)
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      markers = squares.select(&:marked?).collect(&:marker)
      if markers.count(marker) == 2 && markers.size == 2
        risk_square = squares.select(&:unmarked?).first
        return @squares.key(risk_square)
      end
    end
    nil
  end

  def at_risk_square?(marker)
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      markers = squares.select(&:marked?).collect(&:marker)
      if markers.count(marker) == 2 && markers.size == 2
        return true
      end
    end
    false
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def square_five_empty?
    unmarked_keys.include?(5)
  end

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_accessor :marker, :name

  def initialize
    set_name
  end
end

class Human < Player
  def set_name
    n = ""
    loop do
      system "clear"
      puts "What's your name?"
      n = gets.chomp.strip
      break unless n.empty?
      puts "Sorry you must enter a value"
    end
    self.name = n
  end

  def set_marker
    m = nil
    loop do
      puts "Please pick a marker you want to use for this game (X, *, P, +)"
      m = gets.chomp.upcase
      break if %w(X x * p P +).include?(m)
      puts "That is invalid. Please enter X, *, or P"
    end
    self.marker = m
  end
end

class Computer < Player
  def initialize(marker)
    @marker = marker
  end

  def set_name
    self.name = %w(Eva Wall-E R2D2 C3PO).sample
  end
end

class TTTGame
  COMPUTER_MARKER = "O"
  WINNING_SCORE = 3

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Human.new
    @computer = Computer.new(COMPUTER_MARKER)
    @current_marker = nil
    @score = { player: 0, computer: 0 }
    @round = 1
    @human_marker = nil
    @player_pick = nil
  end

  def play
    set_up_game
    loop do
      play_round until grand_winner
      display_grand_winner
      break unless play_again?
      reset
    end
  end

  private

  def set_up_game
    clear
    set_human_marker
    set_computer_name
    first_to_move
    display_first_player
    display_rules
  end

  def play_round
    display_board
    player_move
    next_round_reset
    @round += 1
  end

  def set_human_marker
    @human_marker = human.set_marker
  end

  def set_computer_name
    @computer.set_name
  end

  def prompt_first_player
    answer = nil
    loop do
      prompt_first_player_display
      answer = gets.chomp.to_i
      break if [1, 2, 3].include?(answer)
      puts "Sorry, please enter 1, 2, or 3"
    end
    clear
    answer
  end

  def prompt_first_player_display
    puts "----------- PICK FIRST PLAYER ----------"
    puts ""
    puts "Enter 1 to go first."
    puts "Enter 2 for the computer to go first."
    puts "Enter 3 to be randomly generated."
  end

  def display_first_player
    if @player_pick == @human_marker
      puts "#{human.name} will go first!!"
    else
      puts "#{computer.name} will go first!!"
    end
    puts ""
    ready_for_game
  end

  def first_to_move
    case prompt_first_player
    when 1
      @current_marker = @human_marker && @player_pick = @human_marker
    when 2
      @current_marker = COMPUTER_MARKER && @player_pick = COMPUTER_MARKER
    when 3
      generate_first_player
    end
  end

  def generate_first_player
    whos_first = ["player", "computer"].sample

    if whos_first == "player"
      @current_marker = @human_marker && @player_pick = @human_marker
    elsif @whos_first == "computer"
      @current_marker = COMPUTER_MARKER && @player_history = COMPUTER_MARKER
    end
  end

  # rubocop:disable Metrics/MethodLength
  def display_rules
    clear
    puts <<~HEREDOC
    Welcome to Tic Tac Toe #{human.name}! You are playing against
    #{computer.name}! Here are the rules and how to play!

    => This game is played on a grid that is 3 squares by 3 squares.

    => Each round you will place your marker in one of the empty
      squares by typing in the number of the square and hitting
      enter. For example, if square 1 is empty you would type 1
      and hit enter. That would place your X marker into square
      1.

    => Your objective is to get three of your marks in a row
      across, down, up, or diagonally.

    => The first to get 3 markers in a row wins the round and scores
      1 point.

    => The first to get to 5 points wins the game, and becomes a
      Tic Tac Toe GOD with superhero square picking powers.....
      jk, but you would still be really cool!!

    => Once you have read this and are ready to play hit enter

    "GOOD LUCK AND MAY THE ODDS BE EVER IN YOUR FAVOR"
    HEREDOC
    ready_for_game
  end
  # rubocop:enable Metrics/MethodLength

  def display_board
    scoreboard
    puts "#{human.name}'s marker is: #{@human_marker}"
    puts "#{computer.name}'s marker is a #{COMPUTER_MARKER}."
    puts ""
    board.draw
    puts ""
  end

  def scoreboard
    puts "Round #{@round} Scoreboard: #{@human.name} => #{@score[:player]} "\
    "#{@computer.name} => #{@score[:computer]}"
  end

  def round_winner
    if board.winning_marker == @human_marker
      @score[:player] += 1
      puts "#{@human.name} won! Yay!"
    elsif board.winning_marker == COMPUTER_MARKER
      @score[:computer] += 1
      puts "#{computer.name} won this round."
    else
      puts "It's a tie!"
    end
  end

  def grand_winner
    if @score[:player] == 3 && @score[:computer] == 3
      false
    elsif @score[:player] >= 3 || @score[:computer] >= 3
      true
    else
      false
    end
  end

  def display_grand_winner
    if @score[:player] == 3
      puts "#{human.name} won the game!!!"
    else
      puts "I hate to tell you this; you lost the game!"
    end
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def human_turn?
    @current_marker == @human_marker
  end

  def ready_for_game
    puts "When you are ready to start the game, press the enter button"
    answer = gets.chomp
    sleep until answer
    clear
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def human_moves
    puts "Choose a square (#{board.unmarked_keys.join(', ')}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end
    board[square] = human.marker
  end

  def computer_moves
    square = if board.at_risk_square?(COMPUTER_MARKER)
               board.find_at_risk_square(COMPUTER_MARKER)
             elsif board.at_risk_square?(@human_marker)
               board.find_at_risk_square(@human_marker)
             elsif board.square_five_empty?
               5
             else
               board.unmarked_keys.sample
             end

    board[square] = computer.marker
  end

  def current_player_moves
    if @current_marker == @human_marker
      human_moves
      @current_marker = COMPUTER_MARKER
    else
      computer_moves
      @current_marker = @human_marker
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def clear
    system "clear"
  end

  def divider
    puts "-----------------------------------"
  end

  def ready_for_next_round
    divider
    puts "When you are ready for the next round hit the enter key"
    divider
    answer = gets.chomp
    sleep until answer
    clear
  end

  def next_round_reset
    round_winner
    ready_for_next_round
    @current_marker = @player_pick
    board.reset
    clear
  end

  def reset
    board.reset
    clear
    display_play_again_message
    first_to_move
    display_first_player
    clear
    @score = { player: 0, computer: 0 }
    @round = 1
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end
end

game = TTTGame.new
game.play
