defmodule Parser do
  defp get_expressions() do
    "(a) x := x + 1
(b) y := y + 2z
(c) x := 3x + z
(d) w := w + v
(e) z := y - z
(f) v := x + v"
  end

  defp get_word() do
    "acdcfbbe"
  end

  defp parse_expression(expr) do
    [left, right] = String.split(expr, " := ", parts: 2)
    {left, right}
  end

  # Funkcja, która identyfikuje zmienne w prawej części wyrażenia
  defp identify_variables(right_side) do
    Regex.scan(~r/[a-z]/, right_side)
  end

  # Funkcja tworząca mapę `reads` i `writes` dla pojedynczego wyrażenia
  defp create_read_write_map({label, expr}) do
    {left, right} = parse_expression(expr)
    reads = identify_variables(right)
    writes = [left]
    {label, %{reads: reads |> List.flatten(), writes: writes}}
  end

  # Funkcja przetwarzająca wszystkie wyrażenia na mapę
  def parse_expressions() do
    parse_assignments()
    |> Enum.into(%{}, fn {label, expr} -> create_read_write_map({label, expr}) end)
  end

  # Funkcja zamieniająca sekwencję `w` na listę liter
  def parse_word() do
    get_word()
    |> String.graphemes()
    |> Enum.with_index(fn element, index -> element <> Integer.to_string(index) end)
    |> Enum.map(fn e -> String.to_atom(e) end)
  end

  defp parse_line(line) do
    [left, right] = String.split(line, ") ", parts: 2)

    {Regex.scan(~r'([a-z])', left, capture: :first)
     |> List.flatten()
     |> List.first()
     |> String.to_atom(), right}
  end

  def strip_index(element) do
    element |> Atom.to_string() |> String.first()
  end

  defp parse_assignments() do
    lines = get_expressions() |> String.split("\n")

    for line <- lines do
      parse_line(line)
    end
  end
end
