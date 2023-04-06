defmodule Frontendmmo.AttackPublisher do
  use GenServer
  require IEx
  require Logger

  @channel :attack_channel
  @exchange "frontend-attack-exchange"
  @queue "attack"

  @me __MODULE__

  @enforce_keys [:channel]
  defstruct [:channel]


  ### API ###

  def start_link(_args \\ []) do
    GenServer.start_link(@me, :no_opts, name: @me)
  end

  def can_attack(id, id2) do
     GenServer.call(@me, {:can_attack, id, id2})
  end


  ### CALLBACKS ###

  @impl true
  def init(:no_opts) do
    {:ok, amqp_channel} = AMQP.Application.get_channel(@channel)
    state = %@me{channel: amqp_channel}
    setup_rabbitmq(state)

    {:ok, state}
  end

  @impl true
  def handle_call({:can_attack, id, id2}, _, %@me{channel: c} = state) do
    payload = Jason.encode!(%{command: "attack", id: id, id2: id2})

    :ok = AMQP.Basic.publish(c, @exchange, @queue, payload)
    {:reply, :ok, state}
  end

  ### HELPER FUNCTIONS ###

  defp setup_rabbitmq(%@me{} = state) do
    # Create exchange, queue and bind them.
    :ok = AMQP.Exchange.declare(state.channel, @exchange, :direct)
    {:ok, _consumer_and_msg_info} = AMQP.Queue.declare(state.channel, @queue)
    :ok = AMQP.Queue.bind(state.channel, @queue, @exchange, routing_key: @queue)
  end

end
