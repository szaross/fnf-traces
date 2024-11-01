defmodule Traces do
  @moduledoc """
  A module containing FNF functionality.
  ## Examples

      iex(82)> expressions = Parser.parse_expressions()
      %{
        c: %{reads: ["x", "z"], writes: ["x"]},
        a: %{reads: ["x"], writes: ["x"]},
        f: %{reads: ["x", "v"], writes: ["v"]},
        d: %{reads: ["w", "v"], writes: ["w"]},
        e: %{reads: ["y", "z"], writes: ["z"]},
        b: %{reads: ["y", "z"], writes: ["y"]}
      }
      iex(83)> word = Parser.parse_word()
      [:b0, :a1, :a2, :d3, :c4, :b5]
      iex(84)> words.build_d(expressions)
      [
        [:c, :c],
        [:c, :a],
        [:c, :f],
        [:c, :e],
        [:a, :c],
        [:a, :a],
        [:a, :f],
        [:f, :c],
        [:f, :a],
        [:f, :f],
        [:f, :d],
        [:d, :f],
        [:d, :d],
        [:e, :c],
        [:e, :e],
        [:e, :b],
        [:b, :e],
        [:b, :b]
      ]
      iex(85)> words.build_i(expressions)
      [
        [:c, :d],
        [:c, :b],
        [:a, :d],
        [:a, :e],
        [:a, :b],
        [:f, :e],
        [:f, :b],
        [:d, :c],
        [:d, :a],
        [:d, :e],
        [:d, :b],
        [:e, :a],
        [:e, :f],
        [:e, :d],
        [:b, :c],
        [:b, :a],
        [:b, :f],
        [:b, :d]
      ]
      iex(86)> words.build_fnf(expressions, word)
      [["c"], ["b", "a"], ["b", "a"]]
  """
@doc """
  Build a D set for a set of expressions.
"""
  def build_d(expressions) do
      for x <- Map.keys(expressions), y <- Map.keys(expressions) do
        if Enum.member?(expressions[x].reads,expressions[y].writes |> List.first()) or Enum.member?(expressions[y].reads,expressions[x].writes |> List.first()) do
          [x,y]
        end
      end |> Enum.filter(fn a -> a != nil end)
    end

@doc """
  Build an I set for a set of expressions.
"""
  def build_i(expressions) do
    all_pairs =  for x <- Map.keys(expressions), y <- Map.keys(expressions) do [x,y] end
    all_pairs -- build_d(expressions)
  end

  @doc """
  Build FNF for a set of expressions and a word.
  """
  def build_fnf(expressions, word) do
      expressions
      |> build_d()
      |> build_graph_d(word)
      |> get_foata_classes()
  end

  defp get_foata_classes(graph, classes) do
    if length(Graph.vertices(graph)) == 0  do
      classes
    else
      new_class = Enum.reduce(Graph.vertices(graph), [], fn vertex, class_acc ->
        if length(Graph.in_neighbors(graph, vertex)) == 0 do
          [vertex | class_acc ]
        else
          class_acc
        end
      end)
      # delete all new_class vertices from the graph
      graph = Enum.reduce(new_class,graph, fn action,graph_acc -> Graph.delete_vertex(graph_acc,action) end)
      new_class = new_class |> Enum.map(fn e -> Parser.strip_index(e) end)

      get_foata_classes(graph, [new_class |> Enum.uniq() | classes])
    end
  end

  defp get_foata_classes(graph) do
    # calculate foata classess recursively until there are no more vertices
    get_foata_classes(graph, [])
  end

@doc """
Build a graph for a set of expressions and a word.
Needed to save it to a file.
"""
  def build_graph(expressions, word) do
      expressions
      |> build_d()
      |> build_graph_d(word)
  end

  defp build_graph_d(d, word) do
    initial_graph = Graph.new(type: :directed)
    # go through the word backwards
    Enum.reduce(Enum.with_index(word) |> Enum.reverse(), initial_graph, fn {action, index}, graph_acc ->
      # loop through right hand side of current action
      Enum.reduce(Enum.slice(word, index + 1..-1) , graph_acc, fn other_action, acc_graph ->
        reachable = Graph.reachable(acc_graph, [action])
        # we need to strip vertices from indices to check if two actions are dependent
        action_atom = Parser.strip_index(action) |> String.to_atom()
        other_action_atom = Parser.strip_index(other_action) |> String.to_atom()
        # add an edge if it is not possible to reach other_action from action
        if not Enum.member?(reachable, other_action) and
           (Enum.member?(d, [action_atom, other_action_atom]) or Enum.member?(d, [other_action_atom, action_atom])) do
          Graph.add_edge(acc_graph, action, other_action)
        else
          acc_graph
        end
      end)
    end)
  end

@doc """
  Save a graph to DOT format.
"""
  def save_graph(graph) do
    {:ok, dot_data} = Graph.Serializers.DOT.serialize(graph)
    case File.write("graph.dot", dot_data) do
      :ok -> {:ok, "Successfully saved to graph.dot file" }
      {:error, reason} -> {:error, "Failed to save: #{reason}"}
    end
  end
end
