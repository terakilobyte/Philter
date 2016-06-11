defmodule Philter.TwimlController do
  use Philter.Web, :controller

  def index(conn, _params) do
    song =
      conn.params
      |> get_and_decode_song_request
    render(conn, "index.html", song: song)
  end

  defp get_and_decode_song_request(params) do
    params
    |> Map.get("song")
    |> URI.decode
  end
end
