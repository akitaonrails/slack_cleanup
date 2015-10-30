defmodule SlackCleanup.Files do
  use HTTPoison.Base

  @expected_fields ~w(files)

  def fetch(token) do
    post!("/api/files.list", params(token)).body[:files]
  end

  def process_url(url) do
    "https://slack.com" <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> Dict.take(@expected_fields)
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end

  defp params(token) do
    {:form, [token: token, ts_to: :os.system_time(:seconds)]}
  end
end
