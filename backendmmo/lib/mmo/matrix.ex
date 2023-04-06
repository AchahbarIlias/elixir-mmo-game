defmodule Mmo.Matrix do
  use GenServer

  require Logger

  @me __MODULE__
  defstruct matrix_id: nil, map: {}, players: []

  ### API ###

  def start_link(args) do
    matrix_id = args[:matrix_id] || raise "No matrix id key found \":matrix_id\""
    GenServer.start_link(@me, args, name: tuple(matrix_id))
  end

  def get(id) do
    id
    |> tuple()
    |> GenServer.call(:state)
  end

  def players(id) do
    id
    |> tuple()
    |> GenServer.call(:players)
  end

  def map(id) do
    id
    |> tuple()
    |> GenServer.call(:map)
  end

  def position(x, y) do
    {:ok, id} = get_matrix_id(x, y)

    id
    |> tuple()
    |> GenServer.call({:position, x, y})
  end

  def get_id(x, y) do
    {:ok, id} = get_matrix_id(x, y)

    id
    |> tuple()
    |> GenServer.call(:state)
  end

  def add_player(id, user) do
    id
    |> tuple()
    |> GenServer.call({:add_player, user})
  end

  def delete_player(id, user) do
    id
    |> tuple()
    |> GenServer.call({:delete_player, user})
  end

  ### CALLBACKS ###

  @impl true
  def init(args) do
    {:ok, %@me{matrix_id: args[:matrix_id], map: args[:map]}}
  end

  @impl true
  def handle_call(:state, _from, %@me{} = state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:players, _from, %@me{} = state) do
    {:reply, state.players, state}
  end

  @impl true
  def handle_call(:map, _from, %@me{} = state) do
    {:reply, state.map, state}
  end

  @impl true
  def handle_call({:position, x, y}, _from, %@me{} = state) do
    a = rem(x,20)
    b = rem(y,20)
    {:ok, result} = Enum.fetch(state.map, b)
    {:ok, atom} = is_walkable(String.slice(result, a, 1))
    {:reply, {atom, x, y}, state}
  end

  @impl true
  def handle_call({:add_player, user}, _from, %@me{} = state) do
    {:reply, user, %@me{matrix_id: state.matrix_id,players: state.players ++ [user], map: state.map}}
  end

  @impl true
  def handle_call({:delete_player, user}, _from, %@me{} = state) do
    {:reply, user, %@me{matrix_id: state.matrix_id,players: List.delete(state.players, user), map: state.map}}
  end

  ### HELPER FUNCTIONS ###

  defp tuple(username) do
    {:via, Registry, {Mmo.MyRegistry, {:matrix, username}}}
  end

  defp is_walkable(string) do
    case string do
      "L" ->
        {:ok, :walkable}
      _ ->
        {:ok, :not_walkable}
    end
  end

  def get_matrix_id(x, y) do
      x = div(x,20)
      y = div(y,20)
      result = x + y * 2 + 1

      {:ok, result}
  end
end
