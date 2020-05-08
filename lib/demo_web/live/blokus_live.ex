defmodule DemoWeb.BlokusLive do
  use DemoWeb, :live_view
  alias DemoWeb.BlokusView
  alias Phoenix.PubSub

  def render(assigns) do
    BlokusView.render("multi-user.html", assigns)
  end

  def mount(%{"name" => name, "color" => color}, _session, socket) do
    # if connected?(socket), do: :timer.send_interval(200, self(), :update)

    if connected?(socket), do: PubSub.subscribe Demo.PubSub, "blokus_events"

    {:ok, assign(socket, block_map: %{}, name: name, color: color, selected: 0)}
  end

  def handle_event("toggle", %{"index" => index}, socket) do
    index = String.to_integer(index)
    # {:noreply, assign(socket, :selected, index)}
    name = socket.assigns[:name]
    color = socket.assigns[:color]
    PubSub.broadcast Demo.PubSub, "blokus_events", {:toggle, {:square, index, {:user, name, color}}}
    {:noreply, socket}
  end

  def handle_event("move", %{"code" => "ArrowRight"}, socket) do
    IO.inspect("Right")
    {:noreply, update(socket, :selected, fn previous -> previous + 1 end)}
  end

  def handle_event("move", %{"code" => "ArrowLeft"}, socket) do
    IO.inspect("Left")
    {:noreply, update(socket, :selected, fn previous -> previous - 1 end)}
  end

  # This is important!
  def handle_event("move", %{"code" => x }, socket) do
    IO.inspect("Ignore: #{x}")
    {:noreply, socket}
  end

  def handle_info(:update, socket) do
    {:noreply, update(socket, :selected, fn previous -> rem(previous + 1, 400) end)}
  end

  def handle_info({:block_update, value}, socket) do
    {:noreply, assign(socket, :block_map, value)}
  end

  def handle_info({:block_state, block_map}, socket) do
    {:noreply, assign(socket, :block_map, block_map)}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

end