defmodule DemoWeb.BlokusView do
  use DemoWeb, :view

  def user_names(blokus_map) do
    blokus_map
    |> Map.values()
    |> Enum.map(fn {:user, name, color} -> {name, color} end)
    |> Enum.dedup()
  end

end