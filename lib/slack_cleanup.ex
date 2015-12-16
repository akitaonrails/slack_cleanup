defmodule SlackCleanup do
  alias SlackCleanup.Files
  alias SlackCleanup.Janitor

  def main(args) do
    args |> parse_args |> process
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [domain: :string, token: :string]
    )
    options
  end

  def process([]) do
    IO.puts "Usage: slack_cleanup --token=YOUR_SLACK_TOKEN --domain=YOUR_SLACK_DOMAIN"
  end

  def process(options) do
    Files.fetch(options[:token])
    |> process_files(options)
  end

  defp process_files([files: []], _options) do
    IO.puts("No files to delete.")
  end

  defp process_files(files, options) do
    files[:files]
    |> Enum.map(&Task.async(fn -> Janitor.post(options, &1) end))
    |> Enum.map(&Task.await(&1, 10_000))
    |> Enum.each( fn response -> 
      case response do
        {:ok, permalink}            -> IO.puts "Successfully deleted #{permalink}"
        {:error, permalink, reason} -> IO.puts "Error reason: #{reason} - Failed to delete #{permalink}"
      end
    end)

    process(options)
  end
end
