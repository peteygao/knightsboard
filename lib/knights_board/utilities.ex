defmodule KnightsBoard.Utilities do
  @moduledoc """
  Utility functions common to multiple modules
  """

  def to_coord_atom coordinate do
    coordinate
    |> Enum.join("x")
    |> String.to_atom
  end

  def new_steps_from %{cost: cost, moves: moves}, %{coordinate: coordinate} do
    new_cost  = cost + 1
    new_moves = [coordinate|moves]
    %{cost: new_cost, moves: new_moves}
  end

  def should_cast? %{moves: moves}, %{coordinate: coordinate} do
    cond do
      coordinate in moves ->
        :no_cast
      true ->
        :ok
    end
  end

  def cast_to neighbours, new_steps do
    neighbours
    |> Enum.each(fn neighbour ->
      GenServer.cast neighbour, {:solve, new_steps}
    end)
  end
end
