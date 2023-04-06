defmodule Mmo.PlayersSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Mmo.PlayersDynamicSupervisor},
      {Mmo.PlayerManager, []}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
