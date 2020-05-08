defmodule Demo.BlokusServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    Phoenix.PubSub.subscribe Demo.PubSub, "blokus_events"
   blokus_map = (for n <- 1..400, do: {n, :empty}) |> Map.new()
   {:ok, blokus_map}
  end

  def handle_call(:block_state, _form, blokus_map) do
    {:reply, blokus_map, blokus_map}
  end

  def handle_info({:toggle, {:square, index, {:user, name, color}}}, blokus_map) do

    updated_map = case Map.get(blokus_map, index) do
      {:user, ^name, _} -> Map.put(blokus_map, index, :empty)
      _ -> Map.put(blokus_map, index, {:user, name, color})
    end

    Phoenix.PubSub.broadcast Demo.PubSub, "blokus_events", {:block_state, updated_map}

    {:noreply, updated_map}
  end

  def handle_info(x, state) do
    IO.inspect(x)
    {:noreply, state}
  end

end
