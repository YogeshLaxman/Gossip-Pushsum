defmodule GPS.NodeSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_worker(:gossip) do
    {:ok, pid} = DynamicSupervisor.start_child(__MODULE__, GPS.Gossip.Node)
    pid
  end

  def start_worker(:push_sum, i, start_time) do
    spec = {GPS.PushSum.Node, [i, start_time]}
    {:ok, pid} = DynamicSupervisor.start_child(__MODULE__, spec)
    pid
  end
end
