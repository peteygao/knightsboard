defmodule KnightsBoard.LevelTwo do
  @moduledoc """
  Compute a valid sequence of moves from a given start point to a given end point.
  """

  @board [
    ".", ".", ".", ".", ".", ".", ".", ".",
    ".", ".", ".", ".", ".", ".", ".", ".",
    ".", ".", ".", ".", ".", ".", ".", ".",
    ".", ".", ".", ".", ".", ".", ".", ".",
    ".", ".", ".", ".", ".", ".", ".", ".",
    ".", ".", ".", ".", ".", ".", ".", ".",
    ".", ".", ".", ".", ".", ".", ".", ".",
    ".", ".", ".", ".", ".", ".", ".", ".",
  ]

  def solve([[sx, sy], [ex, ey]]) when
    sx < 1 or sx > 8 or
    sy < 1 or sy > 8 or
    ex < 1 or ex > 8 or
    ey < 1 or ey > 8
  do
    IO.puts [
      "Invalid start or end position: ",
      [sx, sy] |> Enum.join(", "),
      " ",
      [ex, ey] |> Enum.join(", "),
    ]
    :error
  end

  def solve [start_cell, end_cell] do
    {:ok, board} = KnightsBoard.Board.start_link @board

    GenServer.cast board, {:solve, start_cell, end_cell}

    :ok
  end
end
