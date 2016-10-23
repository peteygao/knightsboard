defmodule KnightsBoard.Board do
  alias KnightsBoard.Cell, as: Cell

  @doc """
  Reponsible for initializing all the cells and controls the
  path solver start/end points.
  """

  def start_link board do
    GenServer.start_link(__MODULE__, board, name: :board)
  end

  def init board do
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

        Cell.start_link x, y, cell_type
      end)

    {:ok, %{cells: cells, traces: 0, solutions: []}}
  end

  def handle_cast {:solve, start_cell, end_cell}, state do
    IO.puts [
      "Starting to solve a path from ",
      start_cell |> Enum.join(","),
      " to ",
      end_cell |> Enum.join(","),
      "... (this may take a while)",
    ]

    end_cell_atom = end_cell |> Enum.join("x") |> String.to_atom
    :ok = GenServer.call end_cell_atom, {:set, :end}

    start_cell_atom = start_cell |> Enum.join("x") |> String.to_atom
    :ok = GenServer.cast start_cell_atom, {:solve, %{cost: 0, moves: []}}

    {:noreply, state}
  end

  def handle_cast {:trace_complete, %{cost: _, moves: moves}}, state do
    cond do
      state[:traces] > 1 ->
        new_trace_count = state[:traces] - 1
        new_state       = Map.put state, :traces, new_trace_count
        {:noreply, new_state}
      true ->
        IO.puts "***"
        IO.puts state[:solutions] |> List.first |> Enum.reverse |> Enum.join(":")
        IO.puts "Done! (trace complete)"
        exit(:normal)
    end
  end

  def handle_cast {:solved, %{cost: _, moves: moves}}, state do
    new_trace_count = state[:traces] - 1

    new_state =
      state
      |> Map.put(:solutions, [moves|state[:solutions]])
      |> Map.put(:traces, new_trace_count)

    {:noreply, new_state}
  end

  def handle_call :increment_trace, _from, state do
    new_trace_count = state[:traces] + 1
    new_state       = Map.put state, :traces, new_trace_count
    {:reply, :ok, new_state}
  end

  def terminate reason, _state do
    IO.inspect reason
  end
end
