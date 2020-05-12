defmodule Demo.BlokusServer do
  use GenServer

  def start_link(room) do
    GenServer.start_link(__MODULE__, {room}, name: {:global, {:blokus, room}})
    Phoenix.PubSub.broadcast Demo.PubSub, "blokus_events", {:server_start, room}
  end

  @impl true
  def init({room}) do
   Phoenix.PubSub.subscribe Demo.PubSub, "blokus_events:#{room}:updates"
   blokus_map = (for n <- 1..400, do: {n, :empty}) |> Map.new()
   {:ok, {room, blokus_map}}
  end

  def handle_call(:block_state, _form, {room, blokus_map} = state) do
    {:reply, blokus_map, state}
  end

  def handle_info({:toggle, {:square, index, {:user, name, color}}}, {room, blokus_map}) do

    updated_map = case Map.get(blokus_map, index) do
      {:user, ^name, _} -> Map.put(blokus_map, index, :empty)
      _ -> Map.put(blokus_map, index, {:user, name, color})
    end

    Phoenix.PubSub.broadcast Demo.PubSub, "blokus_events:#{room}:state_change", {:block_state, updated_map}

    {:noreply, {room, updated_map}}
  end

  def handle_info(event, state) do
    IO.inspect(event)
    {:noreply, state}
  end

  def terminate(reason, {room, _}) do
    Phoenix.PubSub.broadcast Demo.PubSub, "blokus_events:#{room}:state_change", :terminated
    Phoenix.PubSub.broadcast Demo.PubSub, "blokus_events", {:server_termination, room}
  end

end
