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
      most_cost:  nil,
      least_cost: nil,
      end_cell:   false,
    }

    {:ok, state}
  end

  def handle_cast(
    {:solve, %{cost: cost, moves: moves}},
    %{
      least_cost: least_cost,
      coordinate: coordinate,
      end_cell:   end_cell,
      cell_type:  cell_type,
      neighbours: neighbours,
    } = state)
  do
    :ok = GenServer.call :board, :increment_trace
    new_moves = [coordinate|moves]
    new_cost  = cost + cell_type_cost(cell_type)
    new_steps = %{cost: new_cost, moves: new_moves}

    new_state = if new_cost < least_cost or least_cost == nil and not end_cell do
      new_state = Map.put state, :least_cost, new_cost

      cond do
        coordinate in moves ->
          GenServer.cast :board, {:trace_complete, new_steps}
        not end_cell ->
          if cell_type == "T" do
            GenServer.cast :board, {:teleport, new_steps}
          else
            neighbours
            |> Enum.each(fn neighbour ->
              GenServer.cast neighbour, {:solve, new_steps}
            end)
          end

          Process.sleep(1)
          GenServer.cast :board, {:trace_complete, new_steps}
        end_cell ->
          GenServer.cast :board, {:solved, new_steps}
        true ->
          # YOLO
      end

      new_state
    else
      GenServer.cast :board, {:trace_complete, new_steps}
      state
    end

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

  def handle_call :get_cell_type, _from, state do
    {:reply, :ok, state[:cell_type]}
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
