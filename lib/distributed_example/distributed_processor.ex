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

    start_time = System.monotonic_time(:millisecond)

    # Create an Agent to track progress
    {:ok, progress_agent} =
      Agent.start_link(fn ->
        %{
          completed: 0,
          successes: 0,
          failures: 0,
          last_print: System.monotonic_time(:millisecond)
        }
      end)

    result =
      1..count
      |> Task.async_stream(
        fn _i ->
          target_node = Enum.random(available_nodes)

          # Process the video
          result =
            Task.Supervisor.async(
              {DistributedExample.FFmpegSupervisor, target_node},
              fn -> DistributedExample.VideoOverlayApp.generate_and_overlay() end
            )
            |> Task.await(300_000)

          # Update progress
          Agent.update(progress_agent, fn state ->
            new_state = %{
              state
              | completed: state.completed + 1,
                successes: state.successes + if(match?({:ok, _}, result), do: 1, else: 0),
                failures: state.failures + if(match?({:error, _}, result), do: 1, else: 0)
            }

            # Print progress every second
            current_time = System.monotonic_time(:millisecond)

            if current_time - state.last_print >= 1000 do
              print_progress_bar(
                new_state.completed,
                count,
                new_state.successes,
                new_state.failures
              )

              %{new_state | last_print: current_time}
            else
              new_state
            end
          end)

          result
        end,
        max_concurrency: 100,
        timeout: 360_000
      )
      |> Enum.reduce({[], []}, fn
        {:ok, {:ok, result}}, {successes, failures} ->
          {[result | successes], failures}

        {:ok, {:error, reason}}, {successes, failures} ->
          {successes, [{:error, reason} | failures]}

        {:exit, reason}, {successes, failures} ->
          {successes, [{:exit, reason} | failures]}
      end)

    # Print final statistics
    end_time = System.monotonic_time(:millisecond)
    duration_sec = (end_time - start_time) / 1000
    {successes, failures} = result

    IO.puts("\n\n📊 Processing Summary:")
    IO.puts("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    IO.puts("✅ Successful: #{length(successes)}")
    IO.puts("❌ Failed: #{length(failures)}")
    IO.puts("⏱️  Total time: #{Float.round(duration_sec, 2)} seconds")
    IO.puts("⚡ Average speed: #{Float.round(count / duration_sec, 2)} videos/second")
    IO.puts("🖥️  Nodes used: #{length(available_nodes)}")
    IO.puts("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")

    Agent.stop(progress_agent)
    result
  end

  # Helper function to print progress bar
  defp print_progress_bar(completed, total, successes, failures) do
    percentage = trunc(completed / total * 100)
    bar_length = 30
    completed_length = trunc(bar_length * percentage / 100)

    bar =
      String.duplicate("█", completed_length) <>
        String.duplicate("░", bar_length - completed_length)

    IO.write("\r[#{bar}] #{percentage}% | ✅ #{successes} ❌ #{failures}")
  end
end
