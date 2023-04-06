defmodule Mmo.PlayersManager do
  use GenServer

  alias Mmo.{Player, PlayerDynamicSupervisor}

  @me __MODULE__
  defstruct players: %{}

  ### API ###

  def start_link(args) do
    GenServer.start_link(@me, args, name: @me)
  end

  def add_new_player(player_id) do
    GenServer.call(@me, {:add_player, player_id})
  end

  def players() do
    GenServer.call(@me, :players)
  end

  def player_exists(player_id) do
    GenServer.call(@me, {:exists_player, player_id})
  end


  ### CALLBACKS ###

  @impl true
  def init(_args), do: {:ok, %@me{}}

  @impl true
  def handle_call(:players, _from, %@me{} = state) do
    {:reply, state.players, state}
  end

  @impl true
  def handle_call({:add_player, username}, _from, %@me{} = state) do
    case Map.has_key?(state.players, username) do
      true ->
        {:reply, {:error, :already_exists}, state}

      false ->
        response = DynamicSupervisor.start_child(PlayerDynamicSupervisor, {Player, [username: username]})
        new_player = Map.put_new(state.players, username, :initialized)
        {:reply, response, %{state | players: new_player}}
    end
  end

  @impl true
  def handle_call({:exists_player, player_id}, _from, %@me{} = state) do
    case Map.has_key?(state.players, player_id) do
      true ->
        {:reply, :exist, state}
      false ->
        {:reply, :doesnt_exist, state}
      end
  end

end
