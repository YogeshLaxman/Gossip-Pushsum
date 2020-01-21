defmodule GPS.PushSum.Node do
  use GenServer, restart: :transient
  # Used the restart policy as "Transient" since
  # we are killing the nodes once the convergance criteria is fulfilled, 
  # and thus don't want the supervisor restarting its children
  # if the they are exited with reason with reason "normal"

  ####################### API ##############################
  def send_message(pid, s, w) do
    GenServer.cast(pid, {:send_next, s, w})
  end

  def add_neighbor(pid, new_neighbor) do
    GenServer.cast(pid, {:add_neighbor, new_neighbor})
  end

  def add_multiple_neighbors(pid, new_neighbors) do
    GenServer.cast(pid, {:set_neighbors, new_neighbors})
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  ####################### SERVER ##############################

  def init([actor_number, start_time]) do
    # IO.puts("init: #{actor_number}")
    {:ok, {[], actor_number, 1, actor_number / 1, 0, start_time}}
  end

  def handle_cast(
        {:send_next, received_s, received_w},
        {neighbors, s, w, sum_estimate, no_change_count, start_time}
      ) do
    s = s + received_s
    w = w + received_w
    change = abs(s / w - sum_estimate)

    no_change_count =
      if change <= :math.pow(10, -10) do
        no_change_count + 1
      else
        0
      end

    active_neighbors = Enum.filter(neighbors, fn pid -> Process.alive?(pid) end)

    if length(active_neighbors) > 0 do
      curr_neighbor = Enum.random(active_neighbors)
      send_message(curr_neighbor, s / 2, w / 2)
    else
      end_time = System.monotonic_time(:millisecond)
      time_taken = end_time - start_time
      IO.puts("Time taken: #{time_taken}")
      System.halt(0)
    end

    if no_change_count >= 3,
      do: exit(:normal),
      else: {:noreply, {neighbors, s / 2, w / 2, s / w, no_change_count, start_time}}
  end

  def handle_cast(
        {:add_neighbor, new_neighbor},
        {neighbors, s, w, sum_estimate, no_change_count, start_time}
      ) do
    {:noreply, {neighbors ++ [new_neighbor], s, w, sum_estimate, no_change_count, start_time}}
  end

  def handle_cast(
        {:set_neighbors, new_neighbors},
        {_neighbors, s, w, sum_estimate, no_change_count, start_time}
      ) do
    {:noreply, {new_neighbors, s, w, sum_estimate, no_change_count, start_time}}
  end
end
