defmodule Traces do
  @moduledoc """
  Documentation for `Traces`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Traces.hello()
      :world

  """
  def hello do
    graph = Graph.new(type: :directed) |> Graph.add_edges([
      {:a,:b}, {:b,:c}
    ])
    Graph.get_shortest_path(graph, :b, :a)
  end

  def build_d(transactions) do
      for x <- Map.keys(transactions), y <- Map.keys(transactions) do
        if Enum.member?(transactions[x].reads,transactions[y].writes |> List.first()) or Enum.member?(transactions[y].reads,transactions[x].writes |> List.first()) do
          [x,y]
        end
      end |> Enum.filter(fn a -> a != nil end)
    end

  def build_i(transactions) do
    all_pairs =  for x <- Map.keys(transactions), y <- Map.keys(transactions) do [x,y] end
    all_pairs -- build_d(transactions)
  end

  def build_fnf(transactions, trace) do
      transactions
      |> build_d()
      |> build_graph_d(trace)
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

  def build_graph(transactions, trace) do
      transactions
      |> build_d()
      |> build_graph_d(trace)
  end

  defp build_graph_d(d, trace) do
    initial_graph = Graph.new(type: :directed)
    # go through the trace backwards
    Enum.reduce(Enum.with_index(trace) |> Enum.reverse(), initial_graph, fn {action, index}, graph_acc ->
      # loop through right hand side of current action
      Enum.reduce(Enum.slice(trace, index + 1..-1) , graph_acc, fn other_action, acc_graph ->
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

  def save_graph(graph) do
    {:ok, dot_data} = Graph.Serializers.DOT.serialize(graph)
    case File.write("graph_dot.dot", dot_data) do
      :ok -> {:ok, "Successfully saved to graph_dot file" }
      {:error, reason} -> {:error, "Failed to save: #{reason}"}
    end
  end
end
