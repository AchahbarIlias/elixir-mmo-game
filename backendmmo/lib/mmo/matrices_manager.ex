defmodule Mmo.MatricesManager do
  use GenServer

  alias Mmo.{Matrix, MatrixDynamicSupervisor}

  @me __MODULE__
  defstruct matrices: %{}, map: {}

  ### API ###

  def start_link(args) do
    {:ok, pid} = GenServer.start_link(@me, args, name: @me)
     Enum.each(1..4, fn x -> create(x) end)
    {:ok, pid}
  end

  def get() do
    GenServer.call(@me, :state)
  end

  def map() do
    GenServer.call(@me, :map)
  end

  ### CALLBACKS ###

  @impl true
  def init(_args) do
    {:ok, contents} = File.read("map.txt")
    contents = contents |> String.split("\r\n", trim: true)
    {:ok, %@me{map: contents}}
  end

  @impl true
  def handle_call(:state, _from, %@me{} = state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:map, _from, %@me{} = state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:add, username}, _from, %@me{} = state) do
    case Map.has_key?(state.matrices, username) do
      true ->
        {:reply, {:error, :already_exists}, state}

      false ->
        {:ok, contents} = File.read("matrices/#{username}.txt")
        contents = contents |> String.split("\n", trim: true)
        response = DynamicSupervisor.start_child(MatrixDynamicSupervisor, {Matrix, [matrix_id: username, map: contents]})
        new_matrix = Map.put_new(state.matrices, username, :not_initialized)
        {:reply, response, %{state | matrices: new_matrix}}
    end
  end

  ### HELPER FUNCTION ###

  defp create(x) do
    GenServer.call(@me, {:add, x})
  end

end
