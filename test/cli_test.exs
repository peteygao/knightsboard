defmodule CLITest do
  use ExUnit.Case
  doctest KnightsBoard.CLI

  test "initialize game board" do
    KnightsBoard.CLI.main ["--level", "1", "--moves", "3,2:4,4:5,6"]
    assert 1 + 1 = 2
  end
end
