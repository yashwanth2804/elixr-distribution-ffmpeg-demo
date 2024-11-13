# DistributedExample

A distributed Elixir application that demonstrates node communication and distributed video processing using FFmpeg.

## Prerequisites

- Elixir 1.17 or later
- FFmpeg installed on all nodes
- Input directory at `/root/elx_img/` with `elx.png` file
- Output directory at `/root/elx_op/`

## Setup and Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd distributed_example
```

2. Install dependencies:
```bash
mix deps.get
```

3. Compile the project:
```bash
mix compile
```

4. Create required directories:
```bash
mkdir -p /root/elx_img
mkdir -p /root/elx_op
```

5. Place your input image:
```bash
# Place your elx.png in the input directory
cp path/to/your/image.png /root/elx_img/elx.png
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

# Process a single video (uses auto-generated filenames)
DistributedExample.DistributedProcessor.process_video()
# Will process /root/elx_img/elx.png and generate:
# - /root/elx_op/output_2024_03_15_10_30_45_123456.mp4

# Process multiple videos in parallel (default: 100 videos)
{successes, failures} = DistributedExample.DistributedProcessor.process_videos_parallel()

# Process a specific number of videos in parallel (e.g., 50)
{successes, failures} = DistributedExample.DistributedProcessor.process_videos_parallel(50)
```

The system will:
1. Automatically connect nodes using the configured cookie
2. Generate a random number using the distributed RandomServer
3. Process the video(s) on randomly selected node(s)
4. Overlay the random number on each video using FFmpeg
5. When processing in parallel:
   - Distributes tasks across all available nodes
   - Processes up to 100 tasks concurrently
   - Returns lists of successful and failed operations

## Directory Structure

- Input image location: `/root/elx_img/elx.png`
- Processed videos will be saved to: `/root/elx_op/`

## Notes

- Ensure FFmpeg is installed on all nodes
- Both nodes must be running on the same machine (WHITE-BEAST in this example)
- To run on different machines, update the node names in `config/config.exs`
- Make sure to use the same cookie value (my_secret_cookie) on all nodes
- The cookie can be set either via command line (as shown above) or in `config/config.exs`
- Ensure the input and output directories exist and have proper permissions

## Troubleshooting

If you encounter issues:
1. Ensure all directories exist and have proper permissions
2. Verify FFmpeg is installed: `ffmpeg -version`
3. Check node connectivity: `Node.list()` in IEx
4. Verify the input file exists: `ls /root/elx_img/elx.png`

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/distributed_example>.

