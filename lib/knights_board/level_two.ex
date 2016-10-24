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
    {:ok, board} =
      KnightsBoard.Board.start_link(
        @board,
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

  defp solution_logic(%{solution: solution} = state, %{moves: moves})
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
      end_cell:   end_cell,
    } = cell_state)
  when
    end_cell == true
  do
    new_steps = new_steps_from steps, cell_state

    GenServer.cast :board, {:solved, new_steps}

    %{least_cost: new_steps[:cost], most_cost: nil}
  end

  defp cell_propagation_logic(
    %{cost: _cost, moves: moves} = steps,
    %{
      coordinate: coordinate,
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
    %{cost: cost, moves: moves} = steps,
    %{
      coordinate: coordinate,
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

  defp new_steps_from %{cost: cost, moves: moves}, %{coordinate: coordinate} do
    new_cost  = cost + 1
    new_moves = [coordinate|moves]
    %{cost: new_cost, moves: new_moves}
  end

  defp should_cast? %{moves: moves}, %{coordinate: coordinate} do
    cond do
      coordinate in moves ->
        :no_cast
      true ->
        :ok
    end
  end

  defp cast_to neighbours, new_steps do
    neighbours
    |> Enum.each(fn neighbour ->
      GenServer.cast neighbour, {:solve, new_steps}
    end)
  end
end
