defmodule Mmo.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Mmo.MyRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: Mmo.PlayerDynamicSupervisor},
      {Mmo.PlayersManager, []},
      {DynamicSupervisor, strategy: :one_for_one, name: Mmo.MatrixDynamicSupervisor},
      {Mmo.MatricesManager, []},
      Mmo.WebserverPublisher,
      Mmo.ManagerOperationsConsumer,
      Mmo.MovementConsumer,
      Mmo.AttackConsumer
    ]

    opts = [strategy: :one_for_one, name: Mmo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
