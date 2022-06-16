defmodule QueryTest do
  use ExUnit.Case, async: true

  setup do
    genserver = GenServer.start(Frontline.Query, [])
    %{genserver: genserver}
  end

  test "calls external api on start" do
    assert !is_nil(GenServer.call(Frontline.Query, :get_state))
  end
end
