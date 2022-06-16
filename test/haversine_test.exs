defmodule HaversineTest do
  use ExUnit.Case

  @p1 {38.8976, -77.0366}
  @p2 {39.9496, -75.1503}

  test "haversine.distance is accurate" do
    assert Float.round(Haversine.distance(@p1, @p2)) == 200
  end
end
