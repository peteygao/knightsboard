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

  def solve do
    board = KnightsBoard.Board.start_link @board
  end
end
