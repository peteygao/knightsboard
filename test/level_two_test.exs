defmodule LevelTwoTest do
  use ExUnit.Case
  doctest KnightsBoard.LevelTwo

  test "single valid move degenerate case" do
    assert KnightsBoard.LevelOne.solve([[3,2]]) == :ok
  end
end
