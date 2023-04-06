defmodule FrontendmmoWeb.GlobalChatChannel do
  use FrontendmmoWeb, :channel

  @impl true
  def join("global_chat:lobby", payload, socket) do
    {:ok, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (global_chat:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end
end
