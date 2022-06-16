defmodule Frontline.Query do
  use GenServer

  alias Phoenix.PubSub
  # Maintain state of:
  # dataset pulled in from api
  # client queries

  # Dataset is pulled in every 5 minutes
  # Each client will receive dataset filtered by their query

  @incident_query "https://services9.arcgis.com/RHVPKKiFTONKtxq3/ArcGIS/rest/services/USA_Wildfires_v1/FeatureServer/0/query?where=POOState+LIKE+%27US%25%27&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=true&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=4326&defaultSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pgeojson&token="

  def start_link(state) do
    {:ok, _} = GenServer.start_link(__MODULE__, state, name: Frontline.Query)
  end

  # Callbacks

  def init(state) do
    Process.send(self(), :query, [:nosuspend])

    {:ok, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:query, _state) do
    incidents =
      HTTPoison.get!(@incident_query).body
      |> Poison.decode!()

    PubSub.broadcast(Frontline.PubSub, "incidents", {:incidents, incidents})

    schedule_query()
    {:noreply, incidents}
  end

  defp schedule_query do
    # Every 5 minutes
    Process.send_after(self(), :query, 300_000)
  end
end



