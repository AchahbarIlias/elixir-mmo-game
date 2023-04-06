defmodule Mmo.AttackConsumer do
  use GenServer
  use AMQP

  require IEx

  @channel :attack_channel
  @exchange "frontend-attack-exchange"
  @queue "attack"

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

  defp process_message(%{"command" => "attack", "id" => id, "id2" => id2} = msg, tag, state) do
    control = Mmo.PlayersManager.player_exists(id2) #Check if the attacked player exists
    case control do 
      :exist ->  #Attacked player exists
        result = Mmo.Player.attack(id, id2)
        Basic.ack(state.channel, tag)
        IO.puts(result)

        case result do
          :hit ->
            %{request: msg, result: "attacked", reason: "- Player #{id} attacked #{id2} for 10hp!"}
            |> Mmo.WebserverPublisher.send_message()
          :miss ->
            %{request: msg, result: "failed", reason: "- Player #{id2} is too far away from #{id} to attack"}
            |> Mmo.WebserverPublisher.send_message()
        end

      :doesnt_exist ->  #Attacked player doesn't exist
        %{request: msg, result: "failed", reason: "- Player #{id} tried to attack no-one"}
        |> Mmo.WebserverPublisher.send_message()
    end
  end

  defp setup_rabbitmq(%@me{} = state) do
    # Create exchange, queue and bind them.
    :ok = AMQP.Exchange.declare(state.channel, @exchange, :direct)
    {:ok, _consumer_and_msg_info} = AMQP.Queue.declare(state.channel, @queue)
    :ok = AMQP.Queue.bind(state.channel, @queue, @exchange, routing_key: @queue)
    :ok = Basic.qos(state.channel, prefetch_count: 5)

    # Register the GenServer process as a consumer. Consumer pid argument (3rd arg) defaults to self()
    {:ok, _unused_consumer_tag} = Basic.consume(state.channel, @queue)
  end
end
