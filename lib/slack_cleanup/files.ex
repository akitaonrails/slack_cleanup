defmodule SlackCleanup.Files do
  @expected_fields ~w(files)

  def fetch(token) do
    case HTTPotion.post("https://slack.com/api/files.list?token=#{token}") do
      %HTTPotion.Response{status_code: 200, body: body} ->
        body
        |> Poison.decode!
        |> Dict.take(@expected_fields)
        |> Enum.map(fn {k, v} ->
             {String.to_atom(k), v}
           end)
      _ -> %{}
    end
  end
end
