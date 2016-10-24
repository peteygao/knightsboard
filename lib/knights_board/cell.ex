defmodule KnightsBoard.Cell do
  use GenServer

  def start_link x, y, cell_type, cell_propagation_logic do
    GenServer.start_link(
      __MODULE__,
      [x, y, cell_type, cell_propagation_logic],
      name: [x, y] |> to_coord_atom
    )
  end

  def init [x, y, cell_type, cell_propagation_logic] do
    state = %{
      coordinate: [x, y] |> to_coord_atom,
      neighbours: get_neighbours(x, y, cell_type),
      cell_type:  cell_type,
      least_cost: nil,
      most_cost:  nil,
      end_cell:   false,
      cell_propagation_logic: cell_propagation_logic,
    }

    {:ok, state}
  end

  def handle_cast({:solve, steps}, %{cell_propagation_logic: cell_propagation_logic} = state) do
    GenServer.cast :board, :increment_trace

    %{least_cost: least_cost, most_cost: most_cost} = cell_propagation_logic.(steps, state)

    new_state = state
    |> Map.put(:least_cost, least_cost)
    |> Map.put(:most_cost, most_cost)

    {:noreply, new_state}
  end

  def handle_cast :print_state, state do
    IO.inspect state
    {:noreply, state}
  end

  def handle_call {:set, :end}, _from, state do
    new_state = Map.put state, :end_cell, true
    {:reply, :ok, new_state}
  end

  defp get_neighbours x, y, cell_type do
    cond do
      cell_type == "." or cell_type == "W" or cell_type == "L" ->
        [
          [x - 2, y - 1 ], [x - 1, y - 2], [x + 1, y - 2], [x + 2, y - 1 ],
          [x - 2, y + 1 ], [x - 1, y + 2], [x + 1, y + 2], [x + 2, y + 1 ],
        ] |> Enum.map(&to_coord_atom/1)
      cell_type == "R" or cell_type == "B" or cell_type == "T" ->
        []
    end
  end

  defp to_coord_atom coordinate do
    coordinate
    |> Enum.join("x")
    |> String.to_atom
  end
end
