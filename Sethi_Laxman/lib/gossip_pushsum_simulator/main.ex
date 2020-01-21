defmodule GPS.Main do
  def main(argv) do
    argv
    |> parse_arguments
    |> start_main
  end

  defp parse_arguments(args) do
    parse = OptionParser.parse(args, aliases: [h: :help], switches: [help: :boolean])

    case parse do
      {[help: true], _, _} ->
        :help

      {_, [num_nodes, topology, algorithm], _} ->
        arguments_converter({num_nodes, topology, algorithm})

      _ ->
        :help
    end
  end

  defp arguments_converter({num_nodes, topology, algorithm}) do
    algorithm =
      case algorithm do
        "push-sum" -> "push_sum"
        "gossip" -> "gossip"
      end

    topology =
      case topology do
        "full" -> "full"
        "line" -> "line"
        "rand2D" -> "rand2D"
        "3Dtorus" -> "torus"
        "honeycomb" -> "honeycomb"
        "randhoneycomb" -> "randhoneycomb"
      end

    {num_nodes, topology, algorithm}
  end

  defp start_main(:help) do
    IO.puts("""
    Usage:
    ./project2 Number_of_nodes topology algorithm
    or
    ./project2 Number_of_nodes topology algorithm failure_percent
    """)

    System.halt(0)
  end

  defp start_main({num_nodes, topology, algorithm}) do
    num_nodes = String.to_integer(num_nodes)
    topology = String.to_atom(topology)
    algorithm = String.to_atom(algorithm)
    start_process(num_nodes, topology, algorithm)
  end

  def start_process(
        num_nodes \\ 100,
        topology \\ :torus,
        algorithm \\ :gossip
      ) do
    start_time = System.monotonic_time(:millisecond)
    # For 3D Torus, we are using the nearest perfect cube to the num of nodes entered
    # For Honeycomb,  we are using the nearest perfect square to the num of nodes entered
    num_nodes =
      case topology do
        :torus -> :math.pow(num_nodes, 1 / 3) |> round() |> :math.pow(3) |> round()
        :honeycomb -> :math.sqrt(num_nodes) |> round() |> :math.pow(2) |> round()
        :randhoneycomb -> :math.sqrt(num_nodes) |> round() |> :math.pow(2) |> round()
        _ -> num_nodes
      end

    case algorithm do
      :gossip ->
        nodes = initialize_nodes(algorithm, num_nodes)
        GPS.Topologies.build_topologies(num_nodes, nodes, topology, algorithm)
        begin_gossip(nodes, start_time)

      :push_sum ->
        nodes = initialize_nodes(algorithm, num_nodes, start_time)
        GPS.Topologies.build_topologies(num_nodes, nodes, topology, algorithm)
        begin_pushsum(nodes, num_nodes)
    end
  end

  defp begin_gossip(nodes_list, start_time) do
    GPS.Gossip.Node.send_message(Enum.random(nodes_list), :rumor)
    check_convergence(nodes_list, start_time)
  end

  defp begin_pushsum(nodes_list, start_time) do
    GPS.PushSum.Node.send_message(Enum.random(nodes_list), 0, 0)
    check_convergence(nodes_list, start_time)
  end

  def check_convergence(nodes_list, start_time) do
    nodes_list = Enum.filter(nodes_list, fn pid -> Process.alive?(pid) end)
    len = length(nodes_list)

    if(len <= 1) do
      end_time = System.monotonic_time(:millisecond)
      time_taken = end_time - start_time
      IO.puts("Time taken: #{time_taken}")
      System.halt(0)
    else
      check_convergence(nodes_list, start_time)
    end
  end

  defp initialize_nodes(:gossip, num_nodes) do
    Enum.map(1..num_nodes, fn _ ->
      GPS.NodeSupervisor.start_worker(:gossip)
    end)
  end

  defp initialize_nodes(:push_sum, num_nodes, start_time) do
    Enum.map(1..num_nodes, fn i ->
      GPS.NodeSupervisor.start_worker(:push_sum, i, start_time)
    end)
  end
end
