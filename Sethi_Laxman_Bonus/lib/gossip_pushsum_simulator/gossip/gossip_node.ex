defmodule GPS.Gossip.Node do
  use GenServer, restart: :transient
  # Used the restart policy as "Transient" since
  # we are killing the nodes once the convergance criteria is fulfilled, 
  # and thus don't want the supervisor restarting its children
  # if the they are exited with reason with reason "normal"

  ####################### API ##############################
  def send_message(pid, message) do
    GenServer.cast(pid, {:send_next, message})
  end

  def add_neighbor(pid, new_neighbor) do
    GenServer.cast(pid, {:add_neighbor, new_neighbor})
  end

  def add_multiple_neighbors(pid, new_neighbors) do
    GenServer.cast(pid, {:set_neighbors, new_neighbors})
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  ####################### SERVER ##############################
  def init(_args) do
    neighbors = []
    count = 0
    is_active = true
    {:ok, {neighbors, count, is_active}}
  end

  def handle_cast({:set_neighbors, new_neighbors}, {_neighbors, count, is_active}) do
    {:noreply, {new_neighbors, count, is_active}}
  end

  def handle_cast({:send_next, message}, {neighbors, count, is_active}) do
    new_count = count + 1

    if new_count == 1 do
      Task.start_link(__MODULE__, :propogate_gossip, [neighbors])
    end

    if new_count == 10 do
      exit(:normal)
    end

    {:noreply, {neighbors, new_count, is_active}}
  end

  def propogate_gossip(neighbors) do
    if length(neighbors) > 0 do
      active_neighbors = Enum.filter(neighbors, fn pid -> Process.alive?(pid) end)

      if length(active_neighbors) > 0 do
        curr_neighbor = Enum.random(active_neighbors)
        send_message(curr_neighbor, :rumor)
        :timer.sleep(100)
        propogate_gossip(active_neighbors)
      end
    end
  end

  def handle_cast({:add_neighbor, new_neighbor}, {neighbors, count, is_active}) do
    {:noreply, {neighbors ++ [new_neighbor], count, is_active}}
  end

  def resend_gossip(pid) do
    Process.send_after(pid, {:gossip_resend}, 500)
  end

  def handle_info({:gossip_resend}, state) do
    send_message(self(), :periodic_message)
    {:noreply, state}
  end

  # Added for testing
  def handle_call({:fetch_neighbors}, _from, {neighbors, count, is_active}) do
    {:reply, neighbors, {neighbors, count, is_active}}
  end

  # Added for testing
  def handle_call({:remove_neighbors, nodes_to_remove}, _from, {neighbors, count, is_active}) do
    new_neighbors = neighbors -- nodes_to_remove
    {:reply, new_neighbors, {new_neighbors, count, is_active}}
  end
end
