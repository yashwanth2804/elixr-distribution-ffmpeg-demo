defmodule DistributedExample.RandomServer do
  use GenServer

  # Starts the GenServer and names it so it can be called from another node
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Initialize the GenServer state
  def init(:ok) do
    {:ok, %{}}
  end

  # Public API to generate a random number
  def generate_random_number do
    GenServer.call(__MODULE__, :generate)
  end

  # Handle synchronous calls
  def handle_call(:generate, _from, state) do
    random_number = :rand.uniform(10)
    {:reply, random_number, state}
  end
end
