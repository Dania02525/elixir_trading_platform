defmodule ElixirExchangeWeb.PageController do
  use ElixirExchangeWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
