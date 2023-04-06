defmodule Frontendmmo.LogDb do
  use GenServer

  @me __MODULE__


  ### API ###
  def start_link(args), do: GenServer.start_link(@me, args, name: @me)
  def store(msg), do: GenServer.cast(@me, {:store, msg})
  def get_logs(:short), do: GenServer.call(@me, {:get_logs, :short})
  def get_logs(:all), do: GenServer.call(@me, {:get_logs, :long})
  def get_logs(:last), do: GenServer.call(@me, {:get_logs, :last})

  ### CALLBACKS ###

  @impl true
  def init(_args) do
     {:ok, []}
  end

  @impl true
  def handle_cast({:store, msg}, state_logs) when is_binary(msg) do
    {:noreply, [msg | state_logs]}
  end

  @impl true
  def handle_cast({:store, msg}, state_logs) when is_map(msg) do
    {:noreply, [Kernel.inspect(msg) | state_logs]}
  end

  @impl true
  def handle_call({:get_logs, :short}, _, state) do
     {:reply, Enum.take(state, 10), state}
  end

  @impl true
  def handle_call({:get_logs, :long}, _, state) do
     {:reply, state, state}
  end

  @impl true
  def handle_call({:get_logs, :last}, _, state) do
  {:reply, Enum.take(state, 1), state}
  
  end



end
