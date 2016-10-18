defmodule LevelOneTest do
  use ExUnit.Case
  doctest KnightsBoard.LevelOne

  test "single valid move degenerate case" do
    assert KnightsBoard.LevelOne.solve([[3,2]]) == :ok
  end

  test "multiple valid moves" do
    assert KnightsBoard.LevelOne.solve([[3,2], [4,4], [5,6]]) == :ok
  end

  test "knight is out of bound" do
    assert KnightsBoard.LevelOne.solve([[8,9]]) == :error
  end

  test "multiple valid moves and an invalid move" do
    assert KnightsBoard.LevelOne.solve([[3,2], [4,4], [5,6], [6,6]]) == :error
  end

  test "multiple valid moves and an out of bound move" do
    assert KnightsBoard.LevelOne.solve([[3,2], [4,4], [9,6], [6,6]]) == :error
  end
end
