defmodule KnightsBoard.Board do
  @moduledoc """
  Reponsible for initializing all the cells and controls the path solver start/end points.
  """

  import KnightsBoard.Utilities
  alias KnightsBoard.Cell, as: Cell

  def start_link(board, solution_logic, cell_propagation_logic, get_neighbours \\ &default_get_neighbours/3) do
    GenServer.start_link(
      __MODULE__,
      [board, solution_logic, cell_propagation_logic, get_neighbours],
      name: :board
    )
  end

  def init [board, solution_logic, cell_propagation_logic, get_neighbours] do
    cells =
      board
      |> Enum.with_index
      |> Enum.map(fn {cell_type, index} ->
        board_width =
          board
          |> length
          |> :math.sqrt
          |> trunc

        y = div(index, board_width) + 1
        x = rem(index, board_width) + 1

        {:ok, cell} = Cell.start_link x, y, cell_type, cell_propagation_logic, get_neighbours
        cell
      end)

    {:ok,
      %{
        cells: cells,
        traces: 0,
        solution: nil,
        solution_logic: solution_logic,
      }
    }
  end

  def handle_cast {:solve, start_cell, end_cell}, state do
    IO.puts [
      "Starting to solve a path from ",
      start_cell |> Enum.join(","),
      " to ",
      end_cell |> Enum.join(","),
      "...",
    ]

    end_cell_atom = end_cell |> Enum.join("x") |> String.to_atom
    :ok = GenServer.call end_cell_atom, {:set, :end}

    start_cell_atom = start_cell |> Enum.join("x") |> String.to_atom
    :ok = GenServer.cast start_cell_atom, {:solve, %{cost: 0, moves: []}}

    {:noreply, state}
  end

  def handle_cast {:trace_complete}, state do
    cond do
      state[:traces] > 1 ->
        new_state = state |> decrement_trace

        {:noreply, new_state}
      state[:traces] == 1 and state[:solution] != nil ->
        IO.puts "Solution:"
        IO.puts state[:solution] |> Enum.reverse |> Enum.join(":")
        state[:cells]
        |> Enum.each(fn cell -> GenServer.stop(cell) end)
        IO.puts "Done! (Ctrl+C to exit)"
        GenServer.stop(:board)
      true ->
        new_state = state |> decrement_trace

        {:noreply, new_state}
    end
  end

  def handle_cast {:solved, steps}, state do
    new_trace_count = state[:traces] - 1

    new_state =
      state
      |> Map.put(:traces, new_trace_count)
      |> state[:solution_logic].(steps)

    {:noreply, new_state}
  end

  def handle_cast :increment_trace, state do
    new_trace_count = state[:traces] + 1
    new_state       = Map.put state, :traces, new_trace_count
    {:noreply, new_state}
  end

  def terminate reason, _state do
    IO.inspect reason
  end

  defp decrement_trace state do
    new_trace_count = state[:traces] - 1
    Map.put state, :traces, new_trace_count
  end

  defp default_get_neighbours x, y, _cell_type do
    [
      [x - 2, y - 1 ], [x - 1, y - 2], [x + 1, y - 2], [x + 2, y - 1 ],
      [x - 2, y + 1 ], [x - 1, y + 2], [x + 1, y + 2], [x + 2, y + 1 ],
    ] |> Enum.map(&to_coord_atom/1)
  end
end
