defmodule KnightsBoard.CLI do
  @help_message """
  Knight's Board Parallel Solver

  This is a parallel solver for the Knight's Board problem, with a total of 4 levels.

  All solutions with the exception of Level 1 is non-deterministic. Which means that the path returned may be different every time the application is invoked, but the path will always satisfy the constraint (i.e. shortest or longest). The reason for this behaviour is because the solver runs in parallel, the first solution that satisfies the constraint will be returned, and there's no guarantee the same path will be found first every run.

  --level -l\tLevel of the Knight's Board to solve for:
            \t Level 1:
            \t  Test if all the --moves parameter are a valid string of Knight moves
            \t Level 2:
            \t  Returns a shortest path from start to end
            \t Level 3:
            \t  Returns a shortest path from start to end on a special 32x32 board (see --board)
            \t Level 4:
            \t  Returns the longest path from start to end on a special 32x32 board (see --board)

  --moves -m\tMove set of the knight (level 1 has special rules, see below)
            \tTo specify start/end grids, use the format:
            \t  3,2:4,4
            \tWhere 3,2 is the coordinate representing the start grid and 4,4 is the grid representing the end grid

            \tBoard dimensions for levels 1 and 2 are 8x8. Levels 3 and 4 are 32x32 (see --board)

            \tSpecial Rules for Level 1:
            \tA chain of moves can be given in the same format, with each move being colon delimited:
            \t  3,2:4,4:5,6

  --board -b\tShows the 32x32 board used for level 3 and 4

  --help -h \tThis help message
  """

  @board """
  **** Special board rules (for level 3 and 4) ****

  1) W[ater] squares count as two moves when a piece lands there
  2) R[ock] squares cannot be used
  3) B[arrier] squares cannot be used AND cannot lie in the path
  4) T[eleport] squares instantly move you from one T to the other in the same move
  5) L[ava] squares count as five moves when a piece lands there

  . . . . . . . . B . . . L L L . . . . . . . . . . . . . . . . .
  . . . . . . . . B . . . L L L . . . . . . . . . . . . . . . . .
  . . . . . . . . B . . . L L L . . . L L L . . . . . . . . . . .
  . . . . . . . . B . . . L L L . . L L L . . . R R . . . . . . .
  . . . . . . . . B . . . L L L L L L L L . . . R R . . . . . . .
  . . . . . . . . B . . . L L L L L L . . . . . . . . . . . . . .
  . . . . . . . . B . . . . . . . . . . . . R R . . . . . . . . .
  . . . . . . . . B B . . . . . . . . . . . R R . . . . . . . . .
  . . . . . . . . W B B . . . . . . . . . . . . . . . . . . . . .
  . . . R R . . . W W B B B B B B B B B B . . . . . . . . . . . .
  . . . R R . . . W W . . . . . . . . . B . . . . . . . . . . . .
  . . . . . . . . W W . . . . . . . . . B . . . . . . T . . . . .
  . . . W W W W W W W . . . . . . . . . B . . . . . . . . . . . .
  . . . W W W W W W W . . . . . . . . . B . . R R . . . . . . . .
  . . . W W . . . . . . . . . . B B B B B . . R R . W W W W W W W
  . . . W W . . . . . . . . . . B . . . . . . . . . W . . . . . .
  W W W W . . . . . . . . . . . B . . . W W W W W W W . . . . . .
  . . . W W W W W W W . . . . . B . . . . . . . . . . . . B B B B
  . . . W W W W W W W . . . . . B B B . . . . . . . . . . B . . .
  . . . W W W W W W W . . . . . . . B W W W W W W B B B B B . . .
  . . . W W W W W W W . . . . . . . B W W W W W W B . . . . . . .
  . . . . . . . . . . . B B B . . . . . . . . . . B B . . . . . .
  . . . . . R R . . . . B . . . . . . . . . . . . . B . . . . . .
  . . . . . R R . . . . B . . . . . . . . . . . . . B . T . . . .
  . . . . . . . . . . . B . . . . . R R . . . . . . B . . . . . .
  . . . . . . . . . . . B . . . . . R R . . . . . . . . . . . . .
  . . . . . . . . . . . B . . . . . . . . . . R R . . . . . . . .
  . . . . . . . . . . . B . . . . . . . . . . R R . . . . . . . .
  """

  @doc """
  Main entry point of the program
  """
  @spec main(list(String.t())) :: { atom() }

  def main(args) do
    {options, _, _} =
      OptionParser.parse(args,
        aliases: [
          b: :board,
          h: :help,
          l: :level,
          m: :moves,
        ]
      )

    options_map = Enum.into(options, %{})

    case options_map do
      %{help: _} ->
        IO.puts @help_message
      %{board: _} ->
        IO.puts @board
      %{level: level, moves: moves} ->
        initialize_board(
          parse_level(level),
          parse_moves(moves)
        )
      %{level: _} ->
        IO.puts "No --moves provided."
      %{moves: _} ->
        IO.puts "No --level provided."
      _ ->
        IO.puts "No --moves provided, and no --level was selected."
    end
  end

  defp initialize_board(level, moves) when is_list(moves) do
    init_message = """
    Game board initialized.
    Level: #{level}
    """

    IO.puts init_message

    case level do
      1 ->
        import KnightsBoard.LevelOne
        solve(moves)
      2 ->
        import KnightsBoard.LevelTwo
        solve(moves)
    end
  end
  defp initialize_board(_, _) do
    exit {:shutdown, 1}
  end

  defp parse_level(level) do
    try do
      String.to_integer level
    catch
      _, _ ->
        IO.puts "Invalid parameter for --level. It was not an integer."
        exit {:shutdown, 1}
    end
  end

  defp parse_moves(moves) do
    try do
      moves
      |> String.split(":")
      |> Enum.map(fn(coords) ->
        String.split(coords, ",")
        |> Enum.map(fn(coord) ->
          String.to_integer coord
        end)
      end)
    catch
      _, _ ->
        IO.puts "Invalid parameters for --moves. See --help for more info."
        exit {:shutdown, 1}
    end
  end

end
