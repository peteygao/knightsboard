defmodule KnightBoardTest do
  use ExUnit.Case
  doctest KnightBoard

  test "initialize game board" do
    KnightBoard.main ["--width", "8", "--height", "8"]
    assert 1 + 1 = 2
  end
end
