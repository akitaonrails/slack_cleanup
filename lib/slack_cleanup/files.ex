defmodule SlackCleanup.Files do
  alias HTTPotion.Response
  alias HTTPotion.HTTPError

  @expected_fields ~w(files)

  def fetch(token) do
    url = "https://slack.com/api/files.list?token=#{token}"
    try do
      case HTTPotion.post(url, timeout: 10_000) do
        %Response{status_code: 200, body: body} ->
          body
          |> Poison.decode!
          |> Dict.take(@expected_fields)
          |> Enum.map(fn {k, v} ->
               {String.to_atom(k), v}
             end)
        _ -> %{}
      end
    rescue
      error in HTTPError ->
        case error do
          %HTTPError{message: "req_timedout"} ->
            :timer.sleep(1_000)
            fetch(token)
        end
    end
  end
end
