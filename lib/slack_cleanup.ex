defmodule SlackCleanup do
  def main(args) do
    args |> parse_args |> process
  end

  def process([]) do
    IO.puts "Usage: slack_cleanup --token=YOUR_SLACK_TOKEN --domain=YOUR_SLACK_DOMAIN"
  end

  def process(options) do
    SlackFiles.fetch(options[:token])
    |> Enum.map( fn (item) -> Task.async(fn -> slack_post(options, item) end) end )
    |> Enum.map( fn (task) -> Task.await(task) end )
    |> Enum.each( fn (response) -> 
      case response do
        {:ok, permalink}            -> IO.puts "Successfully deleted #{permalink}"
        {:error, permalink, reason} -> IO.puts "Failed to delete #{permalink} - #{reason}"
      end
    end)
    IO.puts("Finished.")
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [domain: :string, token: :string]
    )
    options
  end

  defp slack_post(options, item) do
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
