defmodule DistributedExample.DistributedProcessor do
  def process_video() do
    # Get all connected nodes
    nodes = Node.list()

    # Choose a random node from the available nodes
    # Falls back to local node if no other nodes are available
    target_node = if Enum.empty?(nodes), do: node(), else: Enum.random(nodes)

    # Start the supervised task on the target node
    Task.Supervisor.async({DistributedExample.FFmpegSupervisor, target_node}, fn ->
      DistributedExample.VideoOverlayApp.generate_and_overlay()
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

  @doc """
  Processes multiple videos in parallel across available nodes.
  Returns a list of Task references that can be awaited.
  """
  def process_videos_parallel(count \\ 100) do
    nodes = Node.list()
    available_nodes = if Enum.empty?(nodes), do: [node()], else: [node() | nodes]

    1..count
    |> Task.async_stream(
      fn _i ->
        target_node = Enum.random(available_nodes)

        Task.Supervisor.async(
          {DistributedExample.FFmpegSupervisor, target_node},
          fn -> DistributedExample.VideoOverlayApp.generate_and_overlay() end
        )
        # 5 minute timeout per task
        |> Task.await(300_000)
      end,
      # Process 100 tasks concurrently
      max_concurrency: 100,
      # 6 minute overall timeout
      timeout: 360_000
    )
    |> Enum.reduce(
      {[], []},
      fn
        {:ok, {:ok, result}}, {successes, failures} ->
          {[result | successes], failures}

        {:ok, {:error, reason}}, {successes, failures} ->
          {successes, [{:error, reason} | failures]}

        {:exit, reason}, {successes, failures} ->
          {successes, [{:exit, reason} | failures]}
      end
    )
  end
end
