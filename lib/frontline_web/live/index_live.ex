defmodule FrontlineWeb.IndexLive do
  use FrontlineWeb, :live_view

  alias Phoenix.PubSub

  @opts ["US-UT", "US-TX", "US-FL", "US-CA", "US-AZ", "US-NV", "USA", "Near Me"]

  def mount(_params, _session, socket) do
    PubSub.subscribe(Frontline.PubSub, "incidents")

    incident_state = GenServer.call(Frontline.Query, :get_state)

    {:ok,
     socket
     |> assign(options: @opts)
     |> assign(selected_option: "USA")
     |> assign(raw_dataset: incident_state)
     |> assign(geolocation: "")
    }
  end

  def handle_params(_params, _, socket) do
    {:noreply,
     socket
     |> assign(filtered_dataset: filter_data("USA", socket))
    }
  end

  def handle_event("update-geolocation", params, socket) do
    {:noreply,
     socket
     |> assign(geolocation: params)
    }
  end

  def handle_event("change-location", %{"location" => location}, socket) do

    {:noreply,
     socket
     |> assign(selected_option: location)
     |> assign(filtered_dataset: filter_data(location, socket))
    }
  end

  def handle_info({:incidents, raw_dataset}, socket) do
    {:noreply,
     socket
     |> assign(raw_dataset: raw_dataset)}
  end

  defp filter_data("USA", socket) do
    socket.assigns.raw_dataset
    |> Map.fetch!("features")
    |> Enum.reject(&is_nil(Map.fetch!(&1, "properties")["DailyAcres"]))
    |> Enum.sort_by(&Map.fetch!(&1, "properties")["DailyAcres"], :desc)
    |> Enum.take(10)
  end

  defp filter_data("Near Me", socket) do
    geolocation = socket.assigns.geolocation

    socket.assigns.raw_dataset
    |> Map.fetch!("features")
    |> Enum.map(fn x -> Map.put(x, "distance_from_me", create_virtual_distance_field(x, geolocation)) end)
    |> Enum.reject(&(Map.fetch!(&1, "properties")["DailyAcres"] < 100))
    |> Enum.reject(&is_nil(Map.fetch!(&1, "properties")["DailyAcres"]))
    |> Enum.sort_by(&Map.fetch!(&1, "distance_from_me"), :asc)
    |> Enum.take(10)
  end

  defp filter_data(state, socket) do
    socket.assigns.raw_dataset
    |> Map.fetch!("features")
    |> Enum.filter(&(Map.fetch!(&1, "properties")["POOState"] == state))
  end

  defp create_virtual_distance_field(incident, geolocation) do
    incident
    |> Map.fetch!("geometry")
    |> Map.fetch!("coordinates")
    |> Enum.reverse
    |> List.to_tuple
    |> Haversine.distance(List.to_tuple(geolocation))
    |> Float.round(2)
  end
end
