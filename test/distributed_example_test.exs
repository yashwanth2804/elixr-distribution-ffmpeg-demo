defmodule DistributedExampleTest do
  use ExUnit.Case
  doctest DistributedExample

  test "greets the world" do
    assert DistributedExample.hello() == :world
  end
end
