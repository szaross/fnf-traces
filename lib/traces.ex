defmodule Traces do
  @moduledoc """
  A module containing FNF functionality.

  This file is generated. To view it in better format than pdf go to doc/Traces.html
  ## Installation
  To run this you need to install Elixir: https://elixir-lang.org/install.html
  and mix. mix should be installed with Elixir, if not you need to fix it yourself.

  To get all dependencies and run an interactive Elixir shell run the following in project directory:
  ```bash
  mix deps.get
  iex -S mix
  ```
  Then you can use these functionalities:

      iex(82)> expressions = Parser.parse_expressions()
      iex(83)> word = Parser.parse_word()
      iex(84)> Traces.build_d(expressions)
      iex(85)> Traces.build_i(expressions)
      iex(86)> Traces.build_fnf(expressions, word)
      iex(87)> g = Traces.build_graph(expressions, word)
      iex(88)> Traces.save_graph(g)

  To change the input, please go to parser.ex and edit two upmost functions: get_expressions() and get_word() accordingly with proper syntax.
  When done, you can just use `recompile` method in iex and your changes will be updated in the shell.

  Case 1
      iex(1)> Parser.parse_word
      [:a0, :c1, :d2, :c3, :f4, :b5, :b6, :e7]
      iex(2)> expressions = Parser.parse_expressions()
      %{
        c: %{reads: ["x", "z"], writes: ["x"]},
        f: %{reads: ["x", "v"], writes: ["v"]},
        a: %{reads: ["x"], writes: ["x"]},
        d: %{reads: ["w", "v"], writes: ["w"]},
        e: %{reads: ["y", "z"], writes: ["z"]},
        b: %{reads: ["y", "z"], writes: ["y"]}
      }
      iex(3)> word = Parser.parse_word()
      [:a0, :c1, :d2, :c3, :f4, :b5, :b6, :e7]
      iex(4)> Traces.build_d(expressions)
      [
        [:c, :c],
        [:c, :f],
        [:c, :a],
        [:c, :e],
        [:f, :c],
        [:f, :f],
        [:f, :a],
        [:f, :d],
        [:a, :c],
        [:a, :f],
        [:a, :a],
        [:d, :f],
        [:d, :d],
        [:e, :c],
        [:e, :e],
        [:e, :b],
        [:b, :e],
        [:b, :b]
      ]
      iex(5)> Traces.build_i(expressions)
      [
        [:c, :d],
        [:c, :b],
        [:f, :e],
        [:f, :b],
        [:a, :d],
        [:a, :e],
        [:a, :b],
        [:d, :c],
        [:d, :a],
        [:d, :e],
        [:d, :b],
        [:e, :f],
        [:e, :a],
        [:e, :d],
        [:b, :c],
        [:b, :f],
        [:b, :a],
        [:b, :d]
      ]
      iex(6)> Traces.build_fnf(expressions, word)
      [["f", "e"], ["c"], ["c", "b"], ["d", "b", "a"]]
      iex(7)> g = Traces.build_graph(expressions, word)
      #Graph<type: directed, vertices: [:a0, :b5, :b6, :c1, :c3, :d2, :e7, :f4], edges: [:a0 -> :c1, :b5 -> :b6, :b6 -> :e7, :c1 -> :c3, :c3 -> :e7, :c3 -> :f4, :d2 -> :f4]>
      iex(8)> Traces.save_graph g
      {:ok, "Successfully saved to graph.dot file"}

  Case 2
      iex(12)> expressions = Parser.parse_expressions()
      %{
        c: %{reads: ["v", "x"], writes: ["z"]},
        f: %{reads: ["v", "z"], writes: ["v"]},
        a: %{reads: ["x", "y"], writes: ["x"]},
        d: %{reads: ["x", "y"], writes: ["v"]},
        e: %{reads: ["y", "x"], writes: ["x"]},
        b: %{reads: ["z", "v"], writes: ["y"]}
      }
      iex(13)> word = Parser.parse_word()
      [:a0, :f1, :a2, :e3, :f4, :f5, :b6, :c7, :d8]
      iex(14)> Traces.build_d(expressions)
      [
        [:c, :f],
        [:c, :a],
        [:c, :d],
        [:c, :e],
        [:c, :b],
        [:f, :c],
        [:f, :f],
        [:f, :d],
        [:f, :b],
        [:a, :c],
        [:a, :a],
        [:a, :d],
        [:a, :e],
        [:a, :b],
        [:d, :c],
        [:d, :f],
        [:d, :a],
        [:d, :e],
        [:d, :b],
        [:e, :c],
        [:e, :a],
        [:e, :d],
        [:e, :e],
        [:e, :b],
        [:b, :c],
        [:b, :f],
        [:b, :a],
        [:b, :d],
        [:b, :e]
      ]
      iex(15)> Traces.build_i(expressions)
      [[:c, :c], [:f, :a], [:f, :e], [:a, :f], [:d, :d], [:e, :f], [:b, :b]]
      iex(16)> Traces.build_fnf(expressions, word)
      [["d"], ["c"], ["b"], ["f", "e"], ["f", "a"], ["f", "a"]]
      iex(17)> Traces.build_graph(expressions, word)
      #Graph<type: directed, vertices: [:a0, :a2, :b6, :c7, :d8, :e3, :f1, :f4, :f5], edges: [:a0 -> :a2, :a2 -> :e3, :b6 -> :c7, :c7 -> :d8, :e3 -> :b6, :f1 -> :f4, :f4 -> :f5, :f5 -> :b6]>
      iex(19)> Traces.save_graph g
      {:ok, "Successfully saved to graph.dot file"}
  """
  @doc """
    Build a D set for a set of expressions.
  """
  # build dependency set if: one reads var and the other one writes to same var OR two write to the same var
  def build_d(expressions) do
    for x <- Map.keys(expressions), y <- Map.keys(expressions) do
      if Enum.member?(expressions[x].reads, expressions[y].writes |> List.first()) or
           Enum.member?(expressions[y].reads, expressions[x].writes |> List.first()) or
           expressions[x].writes == expressions[y].writes do
        [x, y]
      end
    end
    |> Enum.filter(fn a -> a != nil end)
  end

  @doc """
    Build an I set for a set of expressions.
  """
  # independency set is a set of all pairs minus dependency set
  def build_i(expressions) do
    all_pairs =
      for x <- Map.keys(expressions), y <- Map.keys(expressions) do
        [x, y]
      end

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
    |> Enum.map(&Enum.sort/1)
    |> Enum.uniq()
  end

  # get all the vertices with no ingoing neighbours and then delete them from graph
  defp get_foata_classes(graph, classes) do
    if length(Graph.vertices(graph)) == 0 do
      classes
    else
      new_class =
        Enum.reduce(Graph.vertices(graph), [], fn vertex, class_acc ->
          if length(Graph.in_neighbors(graph, vertex)) == 0 do
            [vertex | class_acc]
          else
            class_acc
          end
        end)

      # delete all new_class vertices from the graph
      graph =
        Enum.reduce(new_class, graph, fn action, graph_acc ->
          Graph.delete_vertex(graph_acc, action)
        end)

      new_class = new_class |> Enum.map(fn e -> Parser.strip_index(e) end)

      get_foata_classes(graph, [new_class | classes])
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
    Enum.reduce(Enum.with_index(word) |> Enum.reverse(), initial_graph, fn {action, index},
                                                                           graph_acc ->
      # loop through right hand side of current action
      Enum.reduce(Enum.slice(word, (index + 1)..-1), graph_acc, fn other_action, acc_graph ->
        reachable = Graph.reachable(acc_graph, [action])
        # we need to strip vertices from indices to check if two actions are dependent
        action_atom = Parser.strip_index(action) |> String.to_atom()
        other_action_atom = Parser.strip_index(other_action) |> String.to_atom()
        # add an edge if it is not possible to reach other_action from action
        if not Enum.member?(reachable, other_action) and
             (Enum.member?(d, [action_atom, other_action_atom]) or
                Enum.member?(d, [other_action_atom, action_atom])) do
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
      :ok -> {:ok, "Successfully saved to graph.dot file"}
      {:error, reason} -> {:error, "Failed to save: #{reason}"}
    end
  end
end
