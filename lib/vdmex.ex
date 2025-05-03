defmodule Vdmex do
  @moduledoc """
  Top Module for Vdmex.
  """
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry,
       [keys: :duplicate, name: Vdmex.Registry, partitions: System.schedulers_online()]},
       {Vdmex.OSCQueryServer, [hostname: "127.0.0.1", modules: %{
        "basic_counter" => Vdmex.Modules.BasicCounter,
       }]}
    ]

    opts = [strategy: :one_for_one, name: Vdmex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
