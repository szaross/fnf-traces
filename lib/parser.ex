defmodule Parser do
  defp get_expressions() do
"(A1,2) A1,2 := M2,1 / M1,1
(B1,1,2) B1,1,2 := M1,1 * A1,2
(C1,1,2) C1,1,2 := M2,1 - B1,1,2
(B1,2,2) B1,2,2 := M1,2 * A1,2
(C1,2,2) C1,2,2 := M2,2 - B1,2,2
(B1,3,2) B1,3,2 := M1,3 * A1,2
(C1,3,2) C1,3,2 := M2,3 - B1,3,2"
  end

  defp get_word() do
    "A1,2 B1,1,2 C1,1,2 B1,2,2 C1,2,2 B1,3,2 C1,3,2"
  end

  defp parse_expression(expr) do
    [left, right] = String.split(expr, " := ", parts: 2)
    {left, right}
  end

  # Funkcja, która identyfikuje zmienne w prawej części wyrażenia
  defp identify_variables(right_side) do
    Regex.scan(~r/[\d\w,]+/, right_side)
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
    |> String.split(" ")
    # |> String.graphemes()
    # |> Enum.with_index(fn element, _index -> element end)
    |> Enum.map(fn e -> String.to_atom(e) end)
  end

  defp parse_line(line) do
    [left, right] = String.split(line, ") ", parts: 2)
    {Regex.scan(~r'([^\(]+)', left, capture: :first)
     |> List.flatten()
     |> List.first()
     |> String.to_atom(), right}
  end

  def strip_index(element) do
    element |> Atom.to_string()
  end

  defp parse_assignments() do
    lines = get_expressions() |> String.split("\n")

    for line <- lines do
      parse_line(line)
    end
  end


  def xd() do
    IO.puts(1 |> xdd)
  end

  def xdd(x) do
    x+2
  end
end
