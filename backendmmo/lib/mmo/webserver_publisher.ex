defmodule Mmo.WebserverPublisher do
  use GenServer
  require IEx
  require Logger

  @channel :webserver_channel
  @exchange "webserver-exchange"
  @queue "webserver-replies"

  @me __MODULE__

  @enforce_keys [:channel]
  defstruct [:channel]


  ### API ###

  def start_link(_args \\ []) do
    GenServer.start_link(@me, :no_opts, name: @me)
  end

  def send_message(payload) do
    GenServer.call(@me, {:send_message, payload})
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
  def handle_call({:send_message, payload}, _, %@me{channel: c} = state) when is_map(payload) do
    payload = Jason.encode!(payload)
    :ok = AMQP.Basic.publish(c, @exchange, @queue, payload)

    #Atom directly send with :ok without knowing that broker has received the message
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
