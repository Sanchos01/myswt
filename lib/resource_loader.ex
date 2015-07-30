defmodule Myswt.ResourceLoader do
	use Silverb, [{"@basic_auth", :application.get_env(:myswt, :basic_auth, nil)}]
	def init(req, path) do
		IO.inspect path
		case {:cowboy_req.parse_header("authorization", req), @basic_auth} do
			{{:basic, login, password}, %{login: login, password: password}} -> File.read!(path) |> reply(req)
			{_, none} when (none == nil) -> File.read!(path) |> reply(req)
			_ -> {:ok, :cowboy_req.reply(401, [{"WWW-Authenticate", "Basic realm=\"wwwest server\""},{"connection","close"}], "", req), nil}
		end
	end
	def terminate(_reason, _req, _state), do: :ok
	defp reply(ans, req), do: {:ok, :cowboy_req.reply(200, [{"Content-Type","text/html; charset=utf-8"},{"connection","close"}], ans, req), nil}
end