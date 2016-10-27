defmodule KnightsBoard.LevelTwo do
  @moduledoc """
  Compute a valid sequence of moves from a given start point to a given end point on a standard 8x8 board.
  """

  import KnightsBoard.Utilities
  use KnightsBoard.Constants

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
    {:ok, board} =
      KnightsBoard.Board.start_link(
        @board,
        8,
        &solution_logic/2,
        &cell_propagation_logic/2
      )

    GenServer.cast board, {:solve, start_cell, end_cell}

    Process.sleep :infinity
  end

  defp solution_logic(
    %{solution: solution} = state,
    %{moves: moves})
  when
    is_nil(solution)
  do
    Map.put state, :solution, moves
  end

  defp solution_logic(
    %{solution: solution} = state,
    %{moves: moves})
  when
    length(moves) < length(solution)
  do
    Map.put state, :solution, moves
  end

  defp solution_logic(state, _) do
    state
  end

  defp cell_propagation_logic(
    steps,
    %{
      end_cell: end_cell,
    } = cell_state)
  when
    end_cell == true
  do
    new_steps = new_steps_from steps, cell_state

    GenServer.cast :board, {:solved, new_steps}

    %{least_cost: new_steps[:cost], most_cost: nil}
  end

  defp cell_propagation_logic(
    steps,
    %{
      least_cost: least_cost,
      neighbours: neighbours,
    } = cell_state)
  when
    is_nil(least_cost)
  do
    new_steps = new_steps_from steps, cell_state

    with :ok <- should_cast?(steps, cell_state),
    do: cast_to(neighbours, new_steps)
    GenServer.cast :board, {:trace_complete}

    %{least_cost: new_steps[:cost], most_cost: nil}
  end

  defp cell_propagation_logic(
    %{cost: cost} = steps,
    %{
      least_cost: least_cost,
      neighbours: neighbours,
    } = cell_state)
  when
    not is_nil(least_cost)
  and
    cost < least_cost
  do
    new_steps = new_steps_from steps, cell_state

    with :ok <- should_cast?(steps, cell_state),
    do: cast_to(neighbours, new_steps)
    GenServer.cast :board, {:trace_complete}

    %{least_cost: new_steps[:cost], most_cost: nil}
  end

  defp cell_propagation_logic(
    _steps,
    %{
      least_cost: least_cost,
    } = _cell_state)
  do
    GenServer.cast :board, {:trace_complete}
    %{least_cost: least_cost, most_cost: nil}
  end
end
