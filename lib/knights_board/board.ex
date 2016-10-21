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
      start_cell |> Enum.join(", "),
      " to ",
      end_cell |> Enum.join(", "),
      "... (this may take a while)",
    ]

    end_cell_atom = end_cell |> Enum.join("x") |> String.to_atom
    :ok = GenServer.call end_cell_atom, {:set, :end}

    start_cell_atom = start_cell |> Enum.join("x") |> String.to_atom
    :ok = GenServer.cast start_cell_atom, {:solve, %{cost: 0, moves: []}}

    new_trace_count = state[:traces] + 1
    new_state       = Map.put state, :traces, new_trace_count

    {:noreply, new_state}
  end

  def handle_cast {:trace_complete, end_cell, %{cost: _, moves: moves}}, state do
    if state[:trace] > 1 and not end_cell do
      new_trace_count = state[:trace] - 1
      new_state       = Map.put state, :traces, new_trace_count
      {:noreply, new_state}
    else
      IO.inspect moves
      IO.puts "Done!"
      exit(:normal)
    end
  end
end
