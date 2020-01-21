defmodule GPS.Topologies do
  def build_topologies(num_nodes, list_nodes, topology_type, algorithm) do
    case topology_type do
      :line -> build_line_topology(list_nodes, algorithm)
      :full -> build_full_topology(list_nodes, algorithm)
      :rand2D -> build_rand2D_topology(list_nodes, algorithm)
      :torus -> build_3Dtorus_topology(num_nodes, list_nodes, algorithm)
      :honeycomb -> build_honeycomb_topology(num_nodes, list_nodes, false, algorithm)
      :randhoneycomb -> build_honeycomb_topology(num_nodes, list_nodes, true, algorithm)
    end
  end

  def build_3Dtorus_topology(num_nodes, list_nodes, algorithm) do
    y = num_nodes |> :math.pow(1 / 3) |> round()
    z = y * y

    for i <- 1..(z * y) do
      rem_iz = rem(i, z)
      rem_iy = rem(i, y)
      z1 = if i <= z, do: i + z * (y - 1), else: i - z
      z2 = if i > z * (y - 1), do: i - z * (y - 1), else: i + z

      cond do
        i == 1 ->
          set_neighbors_helper(
            list_nodes,
            [
              i,
              i + y - 1,
              i + 1,
              i + y,
              i + y * (y - 1),
              z2,
              z1
            ],
            false,
            algorithm
          )

        (rem_iz > y * (y - 1) or rem_iz == 0) and rem_iy == 1 ->
          set_neighbors_helper(
            list_nodes,
            [
              i,
              i + y - 1,
              i + 1,
              i - (y - 1) * y,
              i - y,
              z2,
              z1
            ],
            false,
            algorithm
          )

        (rem_iz > y * (y - 1) or rem_iz == 0) and rem_iy == 0 ->
          set_neighbors_helper(
            list_nodes,
            [
              i,
              i - 1,
              i - y + 1,
              i - (y - 1) * y,
              i - y,
              z2,
              z1
            ],
            false,
            algorithm
          )

        rem(i, z) <= y and rem(i, y) == 1 ->
          set_neighbors_helper(
            list_nodes,
            [
              i,
              i + y - 1,
              i + 1,
              i + y,
              i + (y - 1) * y,
              z2,
              z1
            ],
            false,
            algorithm
          )

        rem(i, z) <= y and rem(i, y) == 0 ->
          set_neighbors_helper(
            list_nodes,
            [
              i,
              i - 1,
              i - y + 1,
              i + y,
              i + (y - 1) * y,
              z2,
              z1
            ],
            false,
            algorithm
          )

        rem_iz > y * (y - 1) or rem_iz == 0 ->
          set_neighbors_helper(
            list_nodes,
            [i, i - 1, i + 1, i - (y - 1) * y, i - y, z2, z1],
            false,
            algorithm
          )

        rem_iz <= y ->
          set_neighbors_helper(
            list_nodes,
            [i, i - 1, i + 1, i + y, i + (y - 1) * y, z2, z1],
            false,
            algorithm
          )

        rem_iy == 1 ->
          set_neighbors_helper(
            list_nodes,
            [i, i + y - 1, i + 1, i + y, i - y, z2, z1],
            false,
            algorithm
          )

        rem_iy == 0 ->
          set_neighbors_helper(
            list_nodes,
            [i, i - 1, i - y + 1, i + y, i - y, z2, z1],
            false,
            algorithm
          )

        true ->
          set_neighbors_helper(
            list_nodes,
            [i, i - 1, i + 1, i + y, i - y, z2, z1],
            false,
            algorithm
          )
      end
    end
  end

  def build_honeycomb_topology(num_nodes, list_nodes, is_random, algorithm) do
    grid_size = :math.sqrt(num_nodes) |> round()

    for i <- 1..(grid_size * grid_size) do
      remainder = rem(i, grid_size)
      remainder_two = rem(remainder, 4)
      remainder_right = rem(grid_size, 4)

      middle =
        i > grid_size and i < grid_size * grid_size - grid_size + 1 and remainder != 0 and
          remainder != 1

      left_line = remainder == 1
      right_line = remainder == 0
      bottom_line = i <= grid_size
      top_line = i > grid_size * grid_size - grid_size + 1

      corner =
        i == 1 or i == grid_size or i == grid_size * grid_size or
          i == grid_size * grid_size + 1 - grid_size

      top_right = i > grid_size * grid_size - 1
      bottom_right = i == grid_size

      cond do
        right_line == true and remainder_right == 0 and top_right == true ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random, algorithm)

        right_line == true and remainder_right == 1 and top_right == true ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random, algorithm)

        right_line == true and remainder_right == 2 and top_right == true ->
          set_neighbors_helper(list_nodes, [i, i - 1, i - grid_size - 1], is_random, algorithm)

        right_line == true and remainder_right == 3 and top_right == true ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random, algorithm)

        right_line == true and remainder_right == 0 and bottom_right == true ->
          set_neighbors_helper(list_nodes, [i, i - 1, i + grid_size - 1], is_random, algorithm)

        right_line == true and remainder_right == 1 and bottom_right == true ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random, algorithm)

        right_line == true and remainder_right == 2 and bottom_right == true ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random, algorithm)

        right_line == true and remainder_right == 3 and bottom_right == true ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random, algorithm)

        right_line == true and remainder_right == 0 and corner == false ->
          set_neighbors_helper(list_nodes, [i, i - 1, i - grid_size - 1], is_random, algorithm)

        right_line == true and remainder_right == 1 and corner == false ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random, algorithm)

        right_line == true and remainder_right == 2 and corner == false ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random, algorithm)

        right_line == true and remainder_right == 3 and corner == false ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random, algorithm)

        remainder_two == 0 and bottom_line == true and corner == false ->
          set_neighbors_helper(
            list_nodes,
            [i, i + 1, i - 1, i + grid_size - 1],
            is_random,
            algorithm
          )

        remainder_two == 1 and bottom_line == true and corner == false ->
          set_neighbors_helper(
            list_nodes,
            [i, i + 1, i - 1, i + grid_size + 1],
            is_random,
            algorithm
          )

        remainder_two == 2 and bottom_line == true and corner == false ->
          set_neighbors_helper(list_nodes, [i, i + 1, i - 1], is_random, algorithm)

        remainder_two == 3 and bottom_line == true and corner == false ->
          set_neighbors_helper(list_nodes, [i, i + 1, i - 1], is_random, algorithm)

        remainder_two == 0 and top_line == true and corner == false ->
          set_neighbors_helper(list_nodes, [i, i + 1, i - 1], is_random, algorithm)

        remainder_two == 1 and top_line == true and corner == false ->
          set_neighbors_helper(list_nodes, [i, i + 1, i - 1], is_random, algorithm)

        remainder_two == 2 and top_line == true and corner == false ->
          set_neighbors_helper(
            list_nodes,
            [i, i + 1, i - 1, i - grid_size - 1],
            is_random,
            algorithm
          )

        remainder_two == 3 and top_line == true and corner == false ->
          set_neighbors_helper(
            list_nodes,
            [i, i + 1, i - 1, i - grid_size + 1],
            is_random,
            algorithm
          )

        remainder_two == 0 and middle == true ->
          set_neighbors_helper(
            list_nodes,
            [i, i + 1, i - 1, i + grid_size - 1],
            is_random,
            algorithm
          )

        remainder_two == 1 and middle == true ->
          set_neighbors_helper(
            list_nodes,
            [i, i + 1, i - 1, i + grid_size + 1],
            is_random,
            algorithm
          )

        remainder_two == 2 and middle == true ->
          set_neighbors_helper(
            list_nodes,
            [i, i + 1, i - 1, i - grid_size - 1],
            is_random,
            algorithm
          )

        remainder_two == 3 and middle == true ->
          set_neighbors_helper(
            list_nodes,
            [i, i + 1, i - 1, i - grid_size + 1],
            is_random,
            algorithm
          )

        left_line == true and i == grid_size * grid_size + 1 - grid_size ->
          set_neighbors_helper(list_nodes, [i, i + 1], is_random, algorithm)

        left_line == true and i != grid_size * grid_size + 1 - grid_size ->
          set_neighbors_helper(list_nodes, [i, i + 1, i + grid_size + 1], is_random, algorithm)

        true ->
          set_neighbors_helper(list_nodes, [i], is_random, algorithm)
      end
    end
  end

  def build_rand2D_topology(list_nodes, algorithm) do
    coordinates_map = Enum.reduce(list_nodes, %{}, &random_coordinates_generator/2)

    Enum.each(coordinates_map, fn {k, v} ->
      [x1, y1] = v

      for x <- Map.keys(coordinates_map) -- [k] do
        [x2, y2] = Map.get(coordinates_map, x)

        if :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2)) <= 0.1 do
          if algorithm == :gossip,
            do: GPS.Gossip.Node.add_neighbor(k, x),
            else: GPS.PushSum.Node.add_neighbor(k, x)
        end
      end
    end)
  end

  defp random_coordinates_generator(elem, map) do
    Map.put(map, elem, [:rand.uniform(), :rand.uniform()])
  end

  def build_full_topology(list_nodes, algorithm) do
    for elem <- list_nodes do
      if algorithm == :gossip,
        do: GPS.Gossip.Node.add_multiple_neighbors(elem, list_nodes -- [elem]),
        else: GPS.PushSum.Node.add_multiple_neighbors(elem, list_nodes -- [elem])
    end
  end

  def build_line_topology(list_nodes, algorithm) do
    num_nodes = length(list_nodes)

    for i <- 0..(num_nodes - 1) do
      cond do
        i == 0 -> set_neighbors_helper_line(list_nodes, [i, i + 1], algorithm)
        i == num_nodes - 1 -> set_neighbors_helper_line(list_nodes, [i, i - 1], algorithm)
        true -> set_neighbors_helper_line(list_nodes, [i, i - 1, i + 1], algorithm)
      end
    end
  end

  defp set_neighbors_helper_line(list_nodes, neighborhood, algorithm) do
    [self_index | neighbors_index] = neighborhood

    neighbors =
      for i <- neighbors_index do
        Enum.at(list_nodes, i)
      end

    if algorithm == :gossip,
      do: GPS.Gossip.Node.add_multiple_neighbors(Enum.at(list_nodes, self_index), neighbors),
      else: GPS.PushSum.Node.add_multiple_neighbors(Enum.at(list_nodes, self_index), neighbors)

    # GenServer.cast(Enum.at(list_nodes, self_index), {:set_neighbors, neighbors})
  end

  defp set_neighbors_helper(list_nodes, neighborhood, is_random, algorithm) do
    [self_index | neighbors_index] = neighborhood
    # Shifted the nodes' position by one because we designed
    # Torus and Honeybcomb with nodes starting at 1 instead of 0
    list_nodes = [nil | list_nodes]

    neighbors =
      for i <- neighbors_index do
        Enum.at(list_nodes, i)
      end

    neighbors =
      if is_random do
        [Enum.random(List.delete_at(list_nodes, 0)) | neighbors]
      else
        neighbors
      end

    if algorithm == :gossip,
      do: GPS.Gossip.Node.add_multiple_neighbors(Enum.at(list_nodes, self_index), neighbors),
      else: GPS.PushSum.Node.add_multiple_neighbors(Enum.at(list_nodes, self_index), neighbors)

    # GenServer.cast(Enum.at(list_nodes, self_index), {:set_neighbors, neighbors})
  end
end
