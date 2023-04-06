defmodule FrontendmmoWeb.PageController do
  use FrontendmmoWeb, :controller

  @topic "global-chat"
  def index(conn, _params) do
    render(conn, "index.html")
  end

  def open_chat(conn, %{"player_id" => player_id}) do 
    render(conn, "chat.html", player_id: player_id)
  end

  def render_game(conn, %{"player_id" => player_id}) do
    data = Frontendmmo.LogDb.get_logs(:last)
    render(conn, "game.html", player_id: player_id, data: data)
  end

  #####
  def logs_short(conn, _) do
    data = Frontendmmo.LogDb.get_logs(:short) |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> text(data)
  end

  def logs_full(conn, _) do
    data = Frontendmmo.LogDb.get_logs(:all) |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> text(data)
  end

  def create_player(conn, %{"player_id" => player_id}) do
    unique_tag = Frontendmmo.PlayerPublisher.create_player(player_id)

    conn
    |> put_flash(:info, "#{player_id} tried creating with tag #{unique_tag}")
    |> redirect(to: Routes.page_path(conn, :render_game, player_id))
end

  def can_walk(conn, %{"player_id" => player_id, "arg" => arg}) do
    arg = String.to_atom(arg)
    _movement = Frontendmmo.MovementPublisher.can_walk(player_id, %{"arg" => "N"})

    text(conn, "Player: #{player_id} tries to move #{arg}")
  end

  def can_attack(conn, %{"player_id" => player_id, "attack_id" => attack_id}) do
    _attack = Frontendmmo.AttackPublisher.can_attack(player_id, attack_id)

    text(conn,"Player: #{player_id} tries to attack player: #{attack_id}")
  end

  def north(conn, %{"player_id" => player_id }) do
    _movement = Frontendmmo.MovementPublisher.can_walk(player_id, "N")

    conn
    |> put_flash(:info, "#{player_id} tried to move north.")
    |> redirect(to: Routes.page_path(conn, :render_game, player_id))
  end

  def east(conn, %{"player_id" => player_id }) do
    _movement = Frontendmmo.MovementPublisher.can_walk(player_id, "E")

    conn
    |> put_flash(:info, "#{player_id} tried to move east.")
    |> redirect(to: Routes.page_path(conn, :render_game, player_id))
 end

  def south(conn, %{"player_id" => player_id }) do
    _movement = Frontendmmo.MovementPublisher.can_walk(player_id, "S")

    conn
    |> put_flash(:info, "#{player_id} tried to move south.")
    |> redirect(to: Routes.page_path(conn, :render_game, player_id))
 end

  def west(conn, %{"player_id" => player_id }) do
    _movement = Frontendmmo.MovementPublisher.can_walk(player_id, "W")

    conn
    |> put_flash(:info, "#{player_id} tried to move west.")
    |> redirect(to: Routes.page_path(conn, :render_game, player_id))
 end

 def attack(conn, %{"player_id" => player_id, "attack_id" => attack_id}) do
    _attack = Frontendmmo.AttackPublisher.can_attack(player_id, attack_id)

    conn
    |> put_flash(:info, "#{player_id} tried to attack #{attack_id}")
    |> redirect(to: Routes.page_path(conn, :render_game, player_id))
  end

end
