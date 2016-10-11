defmodule KnightsBoard.CLI do
  @help_message """
  Knight's Board Parallel Solver

  This is a parallel solver for the Knight's Board problem, with a total of 5 levels.

  All solutions with the exception of Level 1 is non-deterministic. Which means that the path returned may be different every time the application is invoked, but the path will always satisfy the constraint (e.g. shortest, longest, or any valid path). The reason for this behaviour is because the solver runs in parallel, the first solution that satisfies the constraint will be returned, and there's no guarantee the same path will be found first every run.

  --level -l\tLevel of the Knight's Board to solve for:
            \t Level 1:
            \t  Test if all the --moves parameter are a valid string of Knight moves
            \t Level 2:
            \t  Returns any path from start to end coordinates (if possible). Highly likely be the shortest by virtue of the fact that shortest paths computes the fastest.
            \t Level 3:
            \t  Returns a shortest path from start to end (if possible)
            \t Level 4:
            \t  Returns a shortest path from start to end on a specific map (type --map to see it rendered)
            \t Level 5:
            \t  Returns the longest path from start to end on the level 4 board.

  --moves -m\tMove set of the knight (level 1 has special rules, see below)
            \tTo specify start/end grids, use the format:
            \t  3,2:4,4
            \tWhere 3,2 is the coordinate representing the start grid and 4,4 is the grid representing the end grid

            \tSpecial Rules for Level 1:
            \tA chain of moves can be given in the same format, with each move being colon delimited:
            \t  3,2:4,4:5,6

  --help -h \tThis help message
  """
  @doc """
  Main entry point of the program
  """
  @spec main(list(String.t())) :: { atom() }

  def main(args) do
    {options, _, _} =
      OptionParser.parse(args,
        aliases: [
          h: :help,
          l: :level,
          m: :moves,
        ]
      )

    cond do
      Keyword.has_key?(options, :help) ->
        IO.puts @help_message
      Keyword.has_key?(options, :level) and Keyword.has_key?(options, :moves) ->
        initialize_board(
          parse_level(options[:level]),
          parse_moves(options[:moves])
        )
      Keyword.has_key?(options, :level) ->
        IO.puts "No --moves provided."
      Keyword.has_key?(options, :moves) ->
        IO.puts "No --level provided."
      true ->
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
        IO.puts "Invalid parameter for --level. It was not a number."
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
