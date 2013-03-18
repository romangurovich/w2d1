class Board


  def initialize(dimension = 9, no_of_bombs)
    @dimension = dimension
    @field = Array.new(dimension) { |row| Array.new(dimension) }
    @bombs = place_bombs(no_of_bombs)
    @flags = []
  end

  def reveal_squares(root_coords)

  end

  def reveal_bombs(coords)
  end

  def win?
    @flags == @bombs
  end

  def lose?
  end

  def over?
    win? || lose?
  end

  def place_bomb(coords)

  end

  def place_bombs(no_of_bombs)
  end

  def mark_flag(coords)
  end

  def display
    # used transpose so that we can think in [x,y] in the rest
    @field.each_with_index do |row,r_index|
      row.each_with_index do |column, c_index|
        print "#{r_index},#{c_index}"
      end
      puts ""
    end
  end

  def make_move(move_hash)
    # hash with move key and coord value
  end

end


class Player
  def initialize
  end

  def ask_move
    # gets.chomp
  end

  def place_flag(coords)
  end

  def choose_square(coords)
  end

end


class Game
  def initialize(board, player)
    @board = board
    @player = player
  end

  def play
    until over?
      Board.make_move(Player.ask_move)
    end
    win? ? "You win!" : "You lose!"
  end
end