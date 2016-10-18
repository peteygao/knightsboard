defmodule KnightsBoard.LevelOne do
  @moduledoc """
  Accepts a sequence of moves and reports whether the sequence contains only valid knight moves.
  Also print the state of the knight board to the terminal after each move. The current position is marked with a 'K'.
  """

  @doc """
  Accepts a sequence of moves and reports whether the sequence contains only valid knight moves.
  """
  @spec solve(nonempty_list(nonempty_list(String.t))) :: { atom }

  def solve([[x,y]]) when x < 1 or x > 8 or y < 1 or y > 8 do
    IO.puts ["Invalid move: ", Integer.to_string(x), ", ", Integer.to_string(y)]
  end

  def solve [[x,y]|rest] do
    cond do
      [x + 1, y - 2] == List.first(rest) ->
        print_board x, y
        solve rest
      [x + 1, y + 2] == List.first(rest) ->
        print_board x, y
        solve rest
      [x - 1, y - 2] == List.first(rest) ->
        print_board x, y
        solve rest
      [x - 1, y + 2] == List.first(rest) ->
        print_board x, y
        solve rest
      [x + 2, y - 1] == List.first(rest) ->
        print_board x, y
        solve rest
      [x + 2, y + 1] == List.first(rest) ->
        print_board x, y
        solve rest
      [x - 2, y - 1] == List.first(rest) ->
        print_board x, y
        solve rest
      [x - 2, y + 1] == List.first(rest) ->
        print_board x, y
        solve rest
      true ->
        print_board x, y
        IO.puts ["Next move is invalid: ", List.first(rest) |> Enum.map(&Integer.to_string/1) |> Enum.join(", ")]
    end
  end

  defp print_board x, y do
    IO.puts "Print the board. #{Integer.to_string(x)}, #{Integer.to_string(y)}"
  end
end
