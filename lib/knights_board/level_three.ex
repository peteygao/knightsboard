defmodule KnightsBoard.LevelThree do
  @moduledoc """
  Compute a valid sequence of moves from a given start point to a given end point on a special 32x32 board.
  """

  import KnightsBoard.Utilities
  use KnightsBoard.Constants

  @board_width 32
  @board_height 28
  @propagatable_cell_types [".", "W", "L", "T"]

  def solve([[sx, sy], [ex, ey]]) when
    sx < 1 or @board_width < sx or
    sy < 1 or @board_height < sy or
    ex < 1 or @board_width < ex or
    ey < 1 or @board_height < ey
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
        @special_board,
        @board_width,
        &solution_logic/2,
        &cell_propagation_logic/2,
        &get_neighbours/3
      )

    GenServer.cast board, {:solve, start_cell, end_cell}

    Process.sleep :infinity
  end

  defp get_neighbours x, y, cell_type do
    cond do
      cell_type == "." or cell_type == "W" or cell_type == "L" ->
        compute_neighbours(x, y)
      cell_type == "R" or cell_type == "B" or cell_type == "T" ->
        []
    end
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

  defp cell_propagation_logic(steps, %{end_cell: end_cell} = cell_state)
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

  defp compute_neighbours x, y do
    [
      [x - 2, y - 1 ], [x - 1, y - 2], [x + 1, y - 2], [x + 2, y - 1 ],
      [x - 2, y + 1 ], [x - 1, y + 2], [x + 1, y + 2], [x + 2, y + 1 ],
    ]
    |> Enum.filter(&valid_coordinate?/1)
    |> Enum.filter(fn [target_x, target_y] -> valid_move?(x, y, target_x, target_y) end)
    |> Enum.map(&to_coord_atom/1)
  end

  defp valid_coordinate? [target_x, target_y] do
    0 < target_x and target_x <= @board_width and
    0 < target_y and target_y <= @board_width
  end

  defp valid_move? x, y, target_x, target_y do
    # Adjust all coordinate by -1 because cell coordinates are 1 indexed, not 0 indexed
    x = x-1
    y = y-1
    target_x = target_x-1
    target_y = target_y-1

    if abs(x - target_x) > abs(y - target_y) do
      Enum.all?(x..target_x, fn traverse_x ->
        cell_type = Enum.at(@special_board, y * @board_width + traverse_x)

        cell_type in @propagatable_cell_types
      end)
    else
      Enum.all?(y..target_y, fn traverse_y ->
        cell_type = Enum.at(@special_board, traverse_y * @board_width + x)

        cell_type in @propagatable_cell_types
      end)
    end
  end
end
