defmodule DistributedExample.VideoProcessor do
  @moduledoc """
  A module for processing videos using FFmpeg.
  """

  @doc """
  Overlays the specified text onto the input video and saves the result to the output path.
  Uses auto-generated filenames with timestamps.
  """
  def overlay_text(text) do
    input_name = generate_input_filename()
    output_name = generate_output_filename()

    input_path = "/root/elx_img/#{input_name}"
    output_path = "/root/elx_op/#{output_name}"

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
        IO.puts("Video processing completed successfully. Output saved to: #{output_path}")
        {:ok, %{input: input_path, output: output_path}}

      {output, exit_code} ->
        IO.puts("Error during video processing: #{output}")
        {:error, exit_code}
    end
  end

  @doc """
  Generates an input filename with timestamp
  """
  def generate_input_filename do
    timestamp = generate_timestamp()
    "input_#{timestamp}.mp4"
  end

  @doc """
  Generates an output filename with timestamp
  """
  def generate_output_filename do
    timestamp = generate_timestamp()
    "output_#{timestamp}.mp4"
  end

  defp generate_timestamp do
    DateTime.utc_now()
    |> DateTime.to_string()
    |> String.replace(~r/[:\s\-\.]/, "_")
  end
end
