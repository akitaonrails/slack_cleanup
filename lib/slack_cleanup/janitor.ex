defmodule SlackCleanup.Janitor do
  defp post(options, item) do
    url    = delete_url(options[:domain])
    params = delete_params(options[:token], item["id"])
    case HTTPoison.post!(url, params) do
      %HTTPoison.Response{status_code: 200} -> {:ok, item["permalink"]}
      %HTTPoison.Response{status_code: _}   -> {:error, item["permalink"], :not_found}
      %HTTPoison.Error{reason: reason}      -> {:error, item["permalink"], reason}
    end
  end

  defp delete_url(domain) do
    "https://#{domain}.slack.com/api/files.delete?t=#{:os.system_time(:seconds)}"
  end

  defp delete_params(token, file_id) do
    {:form, [token: token, file: file_id, set_active: "true", "_attempts": "1"]}
  end
end
