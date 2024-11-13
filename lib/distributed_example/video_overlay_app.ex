defmodule DistributedExample.VideoOverlayApp do
  @moduledoc """
  A module to generate a random number and overlay it onto a video.
  """

  @doc """
  Generates a random number and overlays it onto a video.
  Uses auto-generated filenames with timestamps.

  ## Returns

    - {:ok, %{input: input_path, output: output_path}} if successful
    - {:error, reason} if an error occurs
  """
  def generate_and_overlay do
    random_number = DistributedExample.RandomServer.generate_random_number()
    text = "Random Number : #{random_number}"

    case DistributedExample.VideoProcessor.overlay_text(text) do
      {:ok, paths} ->
        IO.puts("Overlay completed successfully.")
        {:ok, paths}

      {:error, reason} ->
        IO.puts("Failed to overlay text: #{reason}")
        {:error, reason}
    end
  end
end
