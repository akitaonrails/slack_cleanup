# SlackCleanup

Very simple exercise with Elixir to cleanup unused files from Slack.

The purpose of this small project is just to exercise with Elixir.

## Compiling and Running

You can easily compile like this:

```
mix deps.get
mix escript.build
```

And you should run from the commmand-line like this:

```
./slack_cleanup --domain=YOUR_SLACK_DOMAIN --token=YOUR_SLACK_SECRET_API_TOKEN
```
