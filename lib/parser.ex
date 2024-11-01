defmodule Parser do
  # Funkcja, która rozdziela wyrażenie na składniki
  def parse_expression(expr) do
    [left, right] = String.split(expr, " := ")
    {left, right}
  end

  # Funkcja, która identyfikuje zmienne w prawej części wyrażenia
  def identify_variables(right_side) do
    Regex.scan(~r/[a-z]/, right_side)
  end

  # Funkcja tworząca mapę `reads` i `writes` dla pojedynczego wyrażenia
  def create_read_write_map({label, expr}) do
    {left, right} = parse_expression(expr)
    reads = identify_variables(right)
    writes = [left]
    {label, %{reads: reads |> List.flatten(), writes: writes}}
  end

  # Funkcja przetwarzająca wszystkie wyrażenia na mapę
  def parse_all(assignments) do
    Enum.into(assignments, %{}, fn {label, expr} -> create_read_write_map({label, expr}) end)
  end

  # Funkcja zamieniająca sekwencję `w` na listę liter
  def parse_sequence(sequence) do
    String.graphemes(sequence)  |> Enum.with_index(fn element,index -> element <> Integer.to_string(index) end ) |> Enum.map(fn e -> String.to_atom(e) end)
  end

  def get_assignments() do
    [
      {:a, "x := x + y"},
      {:b, "y := y + 2z"},
      {:c, "x := 3x + z"},
      {:d, "z := y - z"},
    ]
  end

  def strip_index(element) do
    element |> Atom.to_string() |> String.first()
  end
end

# Przykład użycia

# Lista wyrażeń

# Wygenerowanie mapy `reads` i `writes`
# parsed_map = Parser.parse_all(assignments)

# Zamiana `w` na listę liter
# sequence = Parser.parse_sequence("baadcb")

# IO.inspect(parsed_map, label: "Parsed Map")
# IO.inspect(sequence, label: "Sequence")
