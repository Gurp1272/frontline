defmodule FrontlineWeb.PageController do
  use FrontlineWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
