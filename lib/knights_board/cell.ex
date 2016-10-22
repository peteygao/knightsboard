defmodule KnightsBoard.Cell do
  use GenServer

  def start_link x, y, cell_type do
    GenServer.start_link(
      __MODULE__,
      [x, y, cell_type],
      name: [x, y] |> to_coord_atom
    )
  end

  def init [x, y, cell_type] do
    state = %{
      coordinate: [x, y] |> to_coord_atom,
      neighbours: get_neighbours(x, y, cell_type),
      cell_type:  cell_type,
      most_cost:  0,
      least_cost: 0,
      end_cell:   false,
    }

    {:ok, state}
  end

  def handle_cast {:solve, %{cost: cost, moves: moves}}, state do
    :ok = GenServer.call :board, :increment_trace
    new_moves = [state[:coordinate]|moves]
    new_cost  = cost + cell_type_cost(state[:cell_type])
    new_steps = %{cost: new_cost, moves: new_moves}

    cond do
      state[:coordinate] in moves ->
        GenServer.cast :board, {:trace_complete, new_steps}
      not state[:end_cell] ->
        if state[:cell_type] == "T" do
          GenServer.cast :board, {:teleport, new_steps}
        else
          state[:neighbours]
          |> Enum.each(fn neighbour ->
            GenServer.cast neighbour, {:solve, new_steps}
          end)
        end
        GenServer.cast :board, {:trace_complete, new_steps}
      state[:end_cell] ->
        GenServer.call :board, {:solved, new_steps}
      true ->
        # YOLO
    end

    {:noreply, state}
  end

  def handle_cast :print_state, state do
    IO.inspect state
    {:noreply, state}
  end

  def handle_call {:set, :end}, _from, state do
    new_state = Map.put state, :end_cell, true
    {:reply, :ok, new_state}
  end

  defp cell_type_cost(cell_type) when cell_type == "." do
    1
  end
  defp cell_type_cost(cell_type) when cell_type == "L" do
    5
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
