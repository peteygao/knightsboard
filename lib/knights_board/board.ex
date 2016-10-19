defmodule KnightsBoard.Board do
  alias KnightsBoard.Cell, as: Cell

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
        y = div(index, board_width)
        x = rem(index, board_width)

        init_cell_based_on x, y, cell_type
      end)

    %{cells: cells, traces: 0, board: board}
  end

  def handle_call neighbours, from, state do
  end

  defp init_cell_based_on x, y, cell_type do
    case cell_type do
      "." ->
        Cell.start_link x, y, cell_type
      _ ->
        exit {:shutdown, 1}
    end
  end
end
