defmodule KnightsBoard.Cell do
  use GenServer

  @doc """
  Start the Cell controller
  """
  def start_link x, y, cell_type do
    GenServer.start_link(
      __MODULE__,
      [x, y, cell_type],
      name: [x, y] |> Enum.map(&(&1 + 1)) |> Enum.join("x") |> String.to_atom
    )
  end

  def init [x, y] do
    state = %{
      coordinate: [x, y],
      neighbours: get_neighbours(x, y)
    }

    { :ok, state }
  end

  defp get_neighbours x, y do
    [
      [x - 2, y - 1 ], [x - 1, y - 2], [x + 1, y - 2], [x + 2, y - 1 ]
      [x - 2, y + 1 ], [x - 1, y + 2], [x + 1, y + 2], [x + 2, y + 1 ]
    ] |> Enum.map(&to_atom/1)
  end

  defp to_atom coordinate do
    coordinate
    |> Enum.join("x")
    |> String.to_atom
  end
end
