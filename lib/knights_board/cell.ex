defmodule KnightsBoard.Cell do
  @moduledoc """
  Represent each chess board cell as a GenServer process.
  """

  import KnightsBoard.Utilities
  use GenServer

  def start_link x, y, cell_type, cell_propagation_logic, get_neighbours do
    GenServer.start_link(
      __MODULE__,
      [x, y, cell_type, cell_propagation_logic, get_neighbours],
      name: [x, y] |> to_coord_atom
    )
  end

  def init [x, y, cell_type, cell_propagation_logic, get_neighbours] do
    state = %{
      coordinate: [x, y] |> to_coord_atom,
      neighbours: get_neighbours.(x, y, cell_type),
      cell_type:  cell_type,
      least_cost: nil,
      most_cost:  nil,
      end_cell:   false,
      cell_propagation_logic: cell_propagation_logic,
    }

    {:ok, state}
  end

  def handle_cast(
    {:solve, steps},
    %{cell_propagation_logic: cell_propagation_logic} = state
  ) do
    GenServer.cast :board, :increment_trace

    %{least_cost: least_cost, most_cost: most_cost} =
      cell_propagation_logic.(steps, state)

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

  def handle_call :status, _from, state do
    {:reply, state[:neighbours], state}
  end
end
