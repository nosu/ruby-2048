require 'io/console'

class Game
  def initialize(size: 4)
    # the size of the board
    @size       = size
    # the current state of the board
    @board      = Array.new(size).map { Array.new(size, 0) }
    # the maximum number of degits in each column
    @max_digits = Array.new(size, 1)
    # game score
    @score      = 0
  end

  def play
    2.times { generate_a_rand_cell }
    print_board

    while c = STDIN.getch
      if c == ?\C-c
        exit
      elsif c == "\e" && STDIN.getch == '['
        case c_3rd = STDIN.getch
        when "A"
          move("up")
        when "B"
          move("down")
        when "C"
          move("right")
        when "D"
          move("left")
        end
      end
    end
  end

  def generate_a_rand_cell
    cell_value = 2
    gameover if @board.flatten.count(0) == 0

    done = false
    while done == false do
      x = rand(@size)
      y = rand(@size)
      if @board[x][y] == 0
        @board[x][y] = cell_value 
        done = true
      end
    end
  end

  def print_board
    output = ""
    @board.each_with_index do |row, i|
      output += "\n" unless i == 0
      row.each_with_index do |cell, j|
        (@max_digits[j] - cell.to_s.length + 1).times { output += " " }
        output += cell.to_s
      end
    end
    printf output
    move_cursor_back
  end

  def refresh_board
    reset_board(30)
    print_board
  end

  def reset_board(length)
    @size.times do
      length.times {print " "}
      print "\n"
    end
    printf "\e[#{@size - 1}A"
    printf "\e[#{@length}D"
    STDOUT.flush
  end

  def move_cursor_back
    printf "\e[#{@size - 1}A"
    printf "\e[#{@max_digits.inject(@size * 2) {|sum, n| sum + n}}D"
    STDOUT.flush
  end

  def move(key)
    case key
    when "up"
      @board = move_to_left(@board.transpose).transpose
    when "down"
      @board = move_to_right(@board.transpose).transpose
    when "right"
      @board = move_to_right(@board)
    when "left"
      @board = move_to_left(@board)
    end
    # p @board
    generate_a_rand_cell
    refresh_max_digits
    refresh_board
  end

  def move_to_right(board)
    reversed_board = board.map {|row| calc_row_move(row.reverse)}
    reversed_board.map {|row| row.reverse}
  end

  def move_to_left(board)
    board.map {|row| calc_row_move(row)}
  end

  def calc_row_move(row)
    zeros_cut_row = row.select {|cell| cell != 0}
    result = []
    i = 0
    while i < zeros_cut_row.length do
      if zeros_cut_row[i] == zeros_cut_row[i+1] then
        result << (zeros_cut_row[i] * 2)
        i += 2
      else
        result << zeros_cut_row[i]
        i += 1
      end
    end
    (@size - result.length).times {result << 0}
    result
  end

  def refresh_max_digits
    result = Array.new(@size)
    @board.transpose.each_with_index do |row, i|
      result[i] = row.max.to_s.length
    end
    @max_digits = result
  end

  def gameover
    puts "Gameover! (score: #{@score})"
    exit
  end
end

game = Game.new(size: 4)
game.play
