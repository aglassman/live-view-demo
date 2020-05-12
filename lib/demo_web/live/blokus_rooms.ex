defmodule DemoWeb.BlokusRooms do
  use DemoWeb, :live_view
  alias DemoWeb.BlokusView
  alias Phoenix.PubSub
  require IEx;

  def render(assigns) do
    BlokusView.render("blokus_rooms.html", assigns)
  end

  def mount(_params, _session, socket) do

    if connected?(socket), do: PubSub.subscribe Demo.PubSub, "blokus_events"

    rooms = :global.registered_names()
            |> Enum.map(&elem(&1, 1))

    {:ok, assign(socket, rooms: rooms, room_name: "", user_name: "", user_color: "")}
  end

  def handle_event("new-room", %{"room" => %{"name" => name}}, socket) do
    case GenServer.whereis({:global, {:blokus, name}}) do
      nil -> Demo.BlokusServer.start(name)
      _ -> true
    end
    {:noreply, socket}
  end

  def handle_event("user-settings", %{"user" => %{"name" => name, "color" => color}}, socket) do
    {:noreply, assign(socket, user_name: name, user_color: color)}
  end

  def handle_event("kill-room", %{"room" => room}, socket) do
    case GenServer.whereis({:global, {:blokus, room}}) do
      pid -> GenServer.stop(pid, :kill)
    end
    {:noreply, socket}
  end

  def handle_event(event, assigns, socket) do
    IO.inspect([:unhandled, event, assigns])
    {:noreply, socket}
  end

  def handle_info({:server_start, room}, socket) do
    rooms = :global.registered_names()
            |> Enum.map(&elem(&1, 1))
    {:noreply, assign(socket, rooms: rooms)}
  end

  def handle_info({:server_termination, room}, socket) do
    rooms = :global.registered_names()
            |> Enum.map(&elem(&1, 1))
    {:noreply, assign(socket, rooms: rooms)}
  end

  def handle_info(event, socket) do
    IO.inspect(event)
    {:noreply, socket}
  end

end