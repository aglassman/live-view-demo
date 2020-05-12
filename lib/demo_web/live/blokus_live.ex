defmodule DemoWeb.BlokusLive do
  use DemoWeb, :live_view
  alias DemoWeb.BlokusView
  alias Phoenix.PubSub
  require IEx;

  def render(assigns) do
    BlokusView.render("multi-user.html", assigns)
  end

  def mount(%{"name" => name, "color" => color, "room" => room}, _session, socket) do
    # if connected?(socket), do: :timer.send_interval(200, self(), :update)
    IO.puts("MOUNTED")

    if connected?(socket), do: PubSub.subscribe Demo.PubSub, "blokus_events:#{room}:state_change"

    block_map = case GenServer.whereis({:global, {:blokus, room}}) do
      nil ->
        Demo.BlokusServer.start(room)
        %{}
      pid ->
        IO.inspect([:found_room, room, pid])
        GenServer.call({:global, {:blokus, room}}, :block_state)
    end

    {:ok, assign(
      socket,
      terminated: false,
      block_map: block_map,
      room: room,
      name: name,
      color: color,
      selected: 0)}
  end

  def handle_event("toggle", %{"index" => index}, socket) do
    index = String.to_integer(index)
    # {:noreply, assign(socket, :selected, index)}
    name = socket.assigns[:name]
    color = socket.assigns[:color]
    room = socket.assigns[:room]
    PubSub.broadcast Demo.PubSub, "blokus_events:#{room}:updates", {:toggle, {:square, index, {:user, name, color}}}
    {:noreply, socket}
  end

  def handle_event("keypress", %{"code" => "ArrowRight"}, socket) do
    IO.inspect("Right")
    {:noreply, update(socket, :selected, fn i -> i + 1 end)}
  end

  def handle_event("keypress", %{"code" => "ArrowLeft"}, socket) do
    IO.inspect("Left")
    {:noreply, update(socket, :selected, fn i -> i - 1 end)}
  end

  def handle_event("keypress", %{"code" => "ArrowUp"}, socket) do
    IO.inspect("Up")
    {:noreply, update(socket, :selected, fn i -> i - 20 end)}
  end

  def handle_event("keypress", %{"code" => "ArrowDown"}, socket) do
    IO.inspect("Down")
    {:noreply, update(socket, :selected, fn i -> i + 20 end)}
  end

  def handle_event("keypress", %{"code" => "Space"}, socket) do
    IO.inspect("Space")

    index = socket.assigns[:selected]
    name = socket.assigns[:name]
    color = socket.assigns[:color]
    room = socket.assigns[:room]
    PubSub.broadcast Demo.PubSub, "blokus_events:#{room}:updates", {:toggle, {:square, index, {:user, name, color}}}

    {:noreply, socket}
  end

  def handle_event("keypress", %{"code" => x }, socket) do
    IO.inspect("Ignore: #{x}")
    {:noreply, socket}
  end



  # This is important!
  def handle_event(event,assigns,socket) do
    IO.inspect([:unhandled, event, assigns])
    {:noreply, socket}
  end

  # PubSub callbacks
  def handle_info(:update, socket) do
    {:noreply, update(socket, :selected, fn previous -> rem(previous + 1, 400) end)}
  end

  def handle_info({:block_update, value}, socket) do
    {:noreply, assign(socket, :block_map, value)}
  end

  def handle_info({:block_state, block_map}, socket) do
    {:noreply, assign(socket, :block_map, block_map)}
  end

  def handle_info(:terminated, socket) do
    {:noreply, assign(socket, :terminated, true)}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

end