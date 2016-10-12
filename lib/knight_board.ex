defmodule KnightBoard do
  def main(args) do
    {options, _, _} =
      OptionParser.parse(args,
        aliases: [
          h: :height,
          w: :width,
          l: :level,
        ]
      )

    case options do
      [width: width, height: height] ->
        initialize_board width, height
      [level: level] ->
        initialize_board level
      _ ->
        IO.puts "No --width or --height provided, and no --level was selected."
    end
  end

  defp initialize_board width, height do
    init_message = """
    Game board initialized.
    width:  #{width}
    height: #{height}
    """

    IO.puts init_message
  end

  defp initialize_board level do
    init_message = """
    Game board initialized.
    Level: #{level}
    """

    IO.puts init_message
  end
end
