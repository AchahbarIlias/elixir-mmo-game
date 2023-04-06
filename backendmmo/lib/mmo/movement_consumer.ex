defmodule Mmo.MovementConsumer do
  use GenServer
  use AMQP

  require IEx

  @channel :movement_channel
  @exchange "frontend-movement-exchange"
  @queue "movement"

  @me __MODULE__

  @enforce_keys [:channel]
  defstruct [:channel]


  def start_link(args \\ []) do
     GenServer.start_link(@me, args, name: @me)
  end

  def init(_opts) do
    {:ok, amqp_channel} = AMQP.Application.get_channel(@channel)
    state = %@me{channel: amqp_channel}
    setup_rabbitmq(state)
    {:ok, state}
  end


  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, %@me{} = state) do
    {:noreply, state}
  end

  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, %@me{} = state) do
    {:stop, :normal, state}
  end

  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, %@me{} = state) do
    {:noreply, state}
  end

  def handle_info({:basic_deliver, payload, meta_info}, %@me{} = state) do
    payload
    |> Jason.decode!()
    |> process_message(meta_info.delivery_tag, state)

    {:noreply, %@me{} = state}
  end


  ### HELPER FUNCTIONS ###

  defp process_message(%{"command" => "move", "id" => id, "arg" => arg} = msg, tag, state) do
    arg = String.to_atom(arg)
    {result, x, y} = Mmo.Player.walk(id, arg)
    Basic.ack(state.channel, tag)
    IO.puts(result)
    IO.puts(arg)

    case result do
      :walkable ->
        %{request: msg, result: "moved" , reason: "- Player #{id} moved to position (#{x}, #{y})"}
        |> Mmo.WebserverPublisher.send_message()

      :not_walkable ->
        %{request: msg, result: "failed", reason: "- Player #{id} wasn't able to move #{arg} from position (#{x}, #{y})"}
        |> Mmo.WebserverPublisher.send_message()
    end
  end

  defp setup_rabbitmq(%@me{} = state) do
    # Create exchange, queue and bind them.
    :ok = AMQP.Exchange.declare(state.channel, @exchange, :direct)
    {:ok, _consumer_and_msg_info} = AMQP.Queue.declare(state.channel, @queue)
    :ok = AMQP.Queue.bind(state.channel, @queue, @exchange, routing_key: @queue)

    # Limit unacknowledged messages to 1. THIS IS VERY SLOW! Just doing this for debugging
    :ok = Basic.qos(state.channel, prefetch_count: 1)

    # Register the GenServer process as a consumer. Consumer pid argument (3rd arg) defaults to self()
    {:ok, _unused_consumer_tag} = Basic.consume(state.channel, @queue)
  end

end
