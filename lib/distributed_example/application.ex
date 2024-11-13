defmodule DistributedExample.Application do
  use Application

  def start(_type, _args) do
    # fet node and cookie from config
    nodes = Application.get_env(:distributed_example, :node)
    cookie = Application.get_env(:distributed_example, :cookie)

    # set cookie for node
    Node.set_cookie(cookie)

    # connect to all other nodes fromlst with unliess
    Enum.each(nodes, fn node ->
      unless node == Node.self() do
        Node.connect(node)
      end
    end)

    # Start your application supervisor as usual
    children = [
      DistributedExample.RandomServer,
      {Task.Supervisor, name: DistributedExample.FFmpegSupervisor},
      {DynamicSupervisor, name: DistributedExample.TranscodeSupervisor, strategy: :one_for_one}
    ]

    opts = [strategy: :one_for_one, name: DistributedExample.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
