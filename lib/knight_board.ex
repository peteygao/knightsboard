defmodule KnightBoard do
  def main(args) do
    {options, _, _} = OptionParser.parse(args, aliases: [h: :height, w: :width])
    case options do
      [width: width, height: height] ->
        initialize_board width, height
      [level: level] ->
        initialize_board level
      _ ->
        IO.puts "No width or height provided, and no level was selected."
    end
  end

  defp initialize_board width, height do
    IO.puts "Game board initialized."
    IO.puts "width:\t#{width}"
    IO.puts "height:\t#{height}"
  end

  defp initialize_board level do
    IO.puts "Game board initialized."
    IO.puts "Level:\t#{level}"
  end
end
