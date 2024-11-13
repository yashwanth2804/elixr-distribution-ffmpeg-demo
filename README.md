# DistributedExample

A distributed Elixir application that demonstrates node communication and distributed video processing using FFmpeg.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `distributed_example` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:distributed_example, "~> 0.1.0"}
  ]
end
```

## Running the Distributed System

1. Start the first node:
```bash
iex --sname node1@WHITE-BEAST --cookie my_secret_cookie -S mix
```

2. In another terminal, start the second node:
```bash
iex --sname node2@WHITE-BEAST --cookie my_secret_cookie -S mix
```

## Usage Examples

Once both nodes are running, you can process videos across nodes. From any node:

```elixir
# Check connected nodes
DistributedExample.DistributedProcessor.node_status()

# Process a video (uses auto-generated filenames)
DistributedExample.DistributedProcessor.process_video()
# Will generate names like:
# - /root/elx_img/input_2024_03_15_10_30_45_123456.mp4
# - /root/elx_op/output_2024_03_15_10_30_45_123456.mp4
```

The system will:
1. Automatically connect nodes using the configured cookie
2. Generate a random number using the distributed RandomServer
3. Process the video on a randomly selected node
4. Overlay the random number on the video using FFmpeg

## Directory Structure

- Input videos should be placed in: `/root/elx_img/`
- Processed videos will be saved to: `/root/elx_op/`

## Notes

- Ensure FFmpeg is installed on all nodes
- Both nodes must be running on the same machine (WHITE-BEAST in this example)
- To run on different machines, update the node names in `config/config.exs`
- Make sure to use the same cookie value (my_secret_cookie) on all nodes
- The cookie can be set either via command line (as shown above) or in `config/config.exs`
- Ensure the input and output directories exist and have proper permissions

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/distributed_example>.

