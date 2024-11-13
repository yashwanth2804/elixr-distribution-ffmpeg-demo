defmodule DistributedExample.DistributedProcessor do
  def process_video(input_path, output_path) do
    # Get all connected nodes
    nodes = Node.list()

    # Choose a random node from the available nodes
    # Falls back to local node if no other nodes are available
    target_node = if Enum.empty?(nodes), do: node(), else: Enum.random(nodes)

    # Start the supervised task on the target node
    Task.Supervisor.async({DistributedExample.FFmpegSupervisor, target_node}, fn ->
      DistributedExample.VideoOverlayApp.generate_and_overlay(input_path, output_path)
    end)
    # 5 minute timeout, adjust as needed
    |> Task.await(300_000)
  end

  # Optional: Function to check node status
  def node_status do
    nodes = Node.list()
    IO.puts("Connected nodes: #{inspect(nodes)}")
    IO.puts("Current node: #{inspect(node())}")
    {:ok, %{current_node: node(), connected_nodes: nodes}}
  end
end
