defmodule DistributedExample.VideoProcessor do
  @moduledoc """
  A module for processing videos using FFmpeg.
  """

  require Logger

  @doc """
  Overlays the specified text onto the input video and saves the result to the output path.
  Uses auto-generated filenames with timestamps.
  """
  def overlay_text(text) do
    input_path = "/root/elx_img/elx.png"
    output_path = "/root/elx_op/#{generate_output_filename()}"

    Logger.info("Starting video processing on node #{Node.self()}")

    ffmpeg_command = "ffmpeg"

    ffmpeg_args = [
      "-i",
      input_path,
      "-vf",
      "drawtext=text='#{text}':fontsize=24:fontcolor=white:x=10:y=10",
      "-t",
      "10",
      output_path
    ]

    case System.cmd(ffmpeg_command, ffmpeg_args, stderr_to_stdout: true) do
      {_output, 0} ->
        Logger.info(
          "Video processing completed successfully on node #{Node.self()}. Output: #{output_path}"
        )

        {:ok, %{input: input_path, output: output_path, node: Node.self()}}

      {output, exit_code} ->
        Logger.error("Error during video processing on node #{Node.self()}: #{output}")
        {:error, {exit_code, Node.self()}}
    end
  end

  @doc """
  Generates an output filename with timestamp
  """
  def generate_output_filename do
    timestamp =
      DateTime.utc_now()
      |> DateTime.to_string()
      |> String.replace(~r/[:\s\-\.]/, "_")

    "output_#{timestamp}.mp4"
  end
end
