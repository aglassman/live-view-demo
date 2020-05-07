defmodule DemoWeb.BattleshipLive do
  use DemoWeb, :live_view
  alias DemoWeb.BattleshipView

  def render(assigns) do
    BattleshipView.render("index.html", assigns)
  end

  def mount(_params, _session, socket) do

    if connected?(socket), do: :timer.send_interval(1_000, self(), :update)

    {:ok, assign(socket, :val, 0)}
  end

  def handle_event("inc", _value, socket) do
    {:noreply, update(socket, :val, &(&1 + 1))}
  end

  def handle_event("dec", _value, socket) do
    {:noreply, update(socket, :val, &(&1 - 1))}
  end

  def handle_info(:update, socket) do
    {:noreply, update(socket, :val, &(&1 + 1))}
  end

end