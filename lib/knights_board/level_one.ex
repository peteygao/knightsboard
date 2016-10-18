defmodule KnightsBoard.LevelOne do
  @moduledoc """
  Accepts a sequence of moves and reports whether the sequence contains only valid knight moves.
  Also print the state of the knight board to the terminal after each move. The current position is marked with a 'K'.
  """

  @board [
    " . ", " . ", " . ", " . ", " . ", " . ", " . ", " . \n",
    " . ", " . ", " . ", " . ", " . ", " . ", " . ", " . \n",
    " . ", " . ", " . ", " . ", " . ", " . ", " . ", " . \n",
    " . ", " . ", " . ", " . ", " . ", " . ", " . ", " . \n",
    " . ", " . ", " . ", " . ", " . ", " . ", " . ", " . \n",
    " . ", " . ", " . ", " . ", " . ", " . ", " . ", " . \n",
    " . ", " . ", " . ", " . ", " . ", " . ", " . ", " . \n",
    " . ", " . ", " . ", " . ", " . ", " . ", " . ", " . \n",
  ]

  @doc """
  Accepts a sequence of moves and reports whether the sequence contains only valid knight moves.
  """
  @spec solve(nonempty_list(nonempty_list(String.t))) :: { atom }

  def solve([[x,y]]) when x < 1 or x > 8 or y < 1 or y > 8 do
    IO.puts ["Invalid move: ", [x, y] |> Enum.join(", ")]
  end

  def solve [[x, y]] do
    print_board x, y
    IO.puts "All moves are valid"
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
        IO.puts ["Next move is invalid: ", List.first(rest) |> Enum.join(", ")]
    end
  end

  defp print_board x, y do
    ix = x - 1
    iy = y - 1
    board = List.replace_at @board, 8 * iy + ix, " K "

    IO.puts ["Move: ", [x, y] |> Enum.join(", ")]
    IO.puts board
  end
end
