defmodule Mmo.Player do
  use GenServer

  require Logger

  @me __MODULE__
  defstruct username: nil, hp: 100, x: 38, y: 38

  ### API ####

  def start_link(args) do
    player_id = args[:username] || raise "No id key for player \":player_id\" found"
    GenServer.start_link(@me, args, name: tuple(player_id))
  end

  def get(player) do
    player
    |> tuple()
    |> GenServer.call(:state)
  end

  def get_position(player) do
    player
    |> tuple()
    |> GenServer.call(:get_position)
  end

  def walk(player, arg) do
    player
    |> tuple()
    |> GenServer.call({:walk, arg, player})
  end

  def attack(player1, player2) do
    player1
    |> tuple()
    |> GenServer.call({:attack, player2})
  end

  ### CALLBACKS ###

  @impl true
  def init(args) do
    {:ok, pid} = {:ok, %@me{username: args[:username]}}
    state = %@me{}
    {:ok, matrix_id} = Mmo.Matrix.get_matrix_id(state.x, state.y)
    _ = Mmo.Matrix.add_player(matrix_id, args[:username])
    {:ok, pid}
  end

  @impl true
  def handle_call(:state, _from, %@me{} = state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:get_position, _from, %@me{} = state) do
    {:reply, {state.x, state.y}, state}
  end

  @impl true
  def handle_call({:walk, arg, id}, _from, %@me{} = state) do
    x = state.x
    y = state.y

    {:ok, {result, x2, y2}} = direction(arg, x, y)
    {:ok, {x, y}} = walk(result, id, x, y, x2, y2)

    {:reply, {result, x, y}, %@me{x: x, y: y, username: state.username, hp: state.hp}}
  end

  @impl true
  def handle_call({:attack, id2}, _from, %@me{} = state) do
    IO.puts("[#{state.username}] tries to attack player [#{id2}] for 10hp.")
    {x, y} = get_position(id2)

    if (state.x + 1 == x && state.y == y) ||
         (state.x - 1 == x && state.y == y) ||
         (state.x == x && state.y + 1 == y) ||
         (state.x == x && state.y - 1 == y) ||
         (state.x + 1 == x && state.y + 1 == y) ||
         (state.x + 1 == x && state.y - 1 == y) ||
         (state.x - 1 == x && state.y + 1 == y) ||
         (state.x - 1 == x && state.y - 1 == y) do
      IO.puts("[#{state.username}] I hit [#{id2}].")
      hit(id2)
      {:reply, :hit, state}
    else
      IO.puts(
        "[#{state.username}] I missed because [#{id2}] is too far away or on the same tile."
      )

      {:reply, :miss, state}
    end
  end

  @impl true
  def handle_cast(:hit, %@me{} = state) do
    hp = state.hp - 10
    x = state.x
    y = state.y

    if hp < 1 do
      x = 38
      y = 38
      hp = 100
      IO.puts("[#{state.username}] I died!")
      IO.puts("[#{state.username}] I respawned at spawn!")
      {:noreply, %@me{x: x, y: y, username: state.username, hp: hp}}
    else
      {:noreply, %@me{x: x, y: y, username: state.username, hp: hp}}
    end
  end

  ### HELPER FUNCTIONS ###

  defp direction(arg, x, y) do
    case arg do
      :N ->
        {:ok, Mmo.Matrix.position(x, y - 1)}

      :E ->
        {:ok, Mmo.Matrix.position(x + 1, y)}

      :S ->
        {:ok, Mmo.Matrix.position(x, y + 1)}

      :W ->
        {:ok, Mmo.Matrix.position(x - 1, y)}

      _ ->
        {:ok, {:not_walkable, x, y}}
    end
  end

  defp tuple(username) do
    {:via, Registry, {Mmo.MyRegistry, {:player, username}}}
  end

  defp walk(arg, id, x, y, x2, y2) do
    case arg do
      :walkable ->
        _ = is_new_matrix(id, x, y, x2, y2)
        {:ok, {x2, y2}}

      :not_walkable ->
        {:ok, {x, y}}
    end
  end

  defp is_new_matrix(id, x, y, x2, y2) do
    {:ok, a} = Mmo.Matrix.get_matrix_id(x, y)
    {:ok, b} = Mmo.Matrix.get_matrix_id(x2, y2)

    if a != b do
      IO.puts("[#{id}] I have left matrix #{a} and am now in matrix #{b}")
      _ = Mmo.Matrix.delete_player(a, id)
      _ = Mmo.Matrix.add_player(b, id)
      {:ok}
    end
  end

  defp hit(id) do
    id
    |> tuple()
    |> GenServer.cast(:hit)
  end
end
