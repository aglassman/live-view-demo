defmodule DemoWeb.BlokusLive do
  use DemoWeb, :live_view
  alias DemoWeb.BlokusView
  alias Phoenix.PubSub

  def render(assigns) do
    BlokusView.render("index.html", assigns)
  end

  def mount(_params, _session, socket) do

    # if connected?(socket), do: :timer.send_interval(200, self(), :update)

    if connected?(socket), do: PubSub.subscribe Demo.PubSub, "block_select"

    {:ok, assign(socket, :selected, 35)}
  end

  def handle_event("toggle", %{"index" => index}, socket) do
    IO.inspect(index)
    {:noreply, socket}
  end

  def handle_info(:update, socket) do
    {:noreply, update(socket, :selected, fn previous ->:rand.uniform(400) end)}
  end

  def handle_info({:block_select, value}, socket) do
    {:noreply, update(socket, :selected,fn message -> value |> IO.inspect() end)}
  end

end