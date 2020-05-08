defmodule Demo.OnInterval do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    # Schedule work to be performed on start
    schedule_work()

    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    # Do the desired work here
    # ...

    Phoenix.PubSub.broadcast Demo.PubSub, "blokus_events", {:block_update, :rand.uniform(400)}

    # Reschedule once more
    schedule_work()

    {:noreply, state}
  end

  defp schedule_work do
    # In 2 hours
    Process.send_after(self(), :work, 500)
  end
end
