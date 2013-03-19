require 'debugger'

class Board
  attr_accessor :num_board, :squares_revealed, :field

  def initialize(dimension = 9, no_of_bombs=0)
    @dimension = dimension
    @field = Array.new(dimension) { |row| Array.new(dimension) }
    @num_board = @field.deep_dup
    @bombs = []
    place_bombs(no_of_bombs)
    @flags = []
    @squares_revealed = []
  end

  def reveal_square(coords)
    x, y = coords[0], coords[1]
    @squares_revealed << coords
    @field[x][y] = @num_board[x][y]
  end

  def reveal_squares(root_coords)
    x, y = root_coords[0], root_coords[1]
    if @num_board[x][y] == 0
      reveal_square(root_coords)
      zeroes_by_me(root_coords)
    else
      reveal_square(root_coords)
    end
  end

  def reveal_bombs
    @bombs.each do |bomb|
      x, y = bomb[0], bomb[1]
      reveal_square([x,y])
    end
  end

  def win?
    @flags == @bombs
  end

  def lose?
    # bomb represented by *
    @field.any? {|row| row.include?('B')}
  end

  def over?
    win? || lose?
  end

  def place_bomb(coords)
    @bombs << coords
  end

  def place_bombs(no_of_bombs)
    until @bombs.count == no_of_bombs
      bomb = (0...@dimension).to_a.sample, (0...@dimension).to_a.sample
      place_bomb(bomb) unless @bombs.include?(bomb)
    end
  end

  def make_num_board
    (0...@dimension).each do |row|
      (0...@dimension).each do |col|
        if bomb?([row,col])
          @num_board[row][col] = 'B'
        else
          @num_board[row][col] = bombs_by_me([row,col])
        end
      end
     end
  end

  def bomb?(coords)
    @bombs.include?(coords)
  end

  def bombs_by_me(coords)
    x, y = coords[0], coords[1]
    counter = 0

    [ [x, y - 1],
      [x - 1, y - 1],
      [x - 1, y],
      [x - 1, y + 1],
      [x, y + 1],
      [x + 1, y + 1],
      [x + 1, y],
      [x + 1, y - 1] ].each do |coords|
        counter += 1 if bomb?(coords)
      end

    counter
  end

  def zeroes_by_me(coords)
    x, y = coords[0], coords[1]

    [ [x, y - 1],
      [x - 1, y - 1],
      [x - 1, y],
      [x - 1, y + 1],
      [x, y + 1],
      [x + 1, y + 1],
      [x + 1, y],
      [x + 1, y - 1] ].each do |coord|
        if coord.all? {|bound| bound.between?(0,@dimension - 1)} &&
          @num_board[coord[0]][coord[1]].is_a?(Integer) &&
          !@squares_revealed.include?(coord)
          reveal_square(coord)
          zeroes_by_me(coord) if @num_board[coord[0]][coord[1]] == 0
        end
      end
  end

  def mark_flag(coords)
    x, y = coords[0], coords[1]
    @flags << coords
    @field[x][y] = "F"
  end

  def delete_flag(coords)
    x, y = coords[0], coords[1]
    @flags.delete(coords)
    @field[x][y] = nil
  end

  def display
    puts "\n"
    @field
  end

  def print_board(printing_board)
    printing_board.each_with_index do |row, r_index|
      puts
      row.each_with_index do |column, c_index|
        if printing_board[r_index][c_index].nil?
          print " * "
        else
          print " #{printing_board[r_index][c_index]} "
        end
      end
    end
    2.times {puts}
  end

  def make_move(move_hash)
    key = move_hash.keys.first
    case key
    when "flag"
      mark_flag(move_hash[key])
    when "unflag"
      delete_flag(move_hash[key])
    when "reveal"
      reveal_squares(move_hash[key])
    else
      puts "That is not a valid move. Valid moves are: "
      puts "flag, unflag, reveal"
    end
  end
end


class Player
  def initialize
  end

  def ask_move
    puts "Enter x,y and your move type like so: 1,2 flag"
    user_input = gets.chomp
    user_input_array = user_input.match(/^(\d),(\d)\s+(\w+)/)
    x, y, move = $1, $2, $3
    {move => translate(x,y)}
  end

  def translate(x,y)
    [y.to_i - 1, x.to_i - 1]
  end
end


class Game
  def initialize(board, player)
    @board = board
    @player = player
    @board.make_num_board
    @start_time = Time.now
    @end_time = 0
  end

  def play
    until @board.over?
      @board.print_board(@board.field)
      @board.make_move(@player.ask_move)
    end
    @board.reveal_bombs
    @board.print_board(@board.num_board)
    puts @board.win? ? "You win!" : "You lose!"
    @end_time = Time.now
    time_taken = @end_time - @start_time
    puts "You took #{time_taken.floor} seconds"
  end

  def save_game(game_name)
    File.open("./#{game_name}.txt", "a") do |f|
      f.puts @board.field
      f.puts "---"
      f.puts @board.num_board
    end
  end
end

class Array
  def deep_dup
    # Argh! Mario and Kriti beat me with a one line version?? Must
    # have used `inject`...
    new_array = []
    self.each do |el|
      if el.is_a?(Array)
        new_array << el.deep_dup
      else
        new_array << el
      end
    end

    new_array
  end
end

# g = Game.new(Board.new(9,10), Player.new)
# g.play
