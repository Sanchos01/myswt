defmodule Myswt.ResourceLoader do
	use Silverb, [{"@basic_auth", :application.get_env(:myswt, :basic_auth, nil)}]
	def init(_, req, [path]) do
		case {:cowboy_req.parse_header("authorization", req), @basic_auth} do
			{{:ok, {"basic",{login,password}}, req}, %{login: login, password: password}} -> File.read!(path) |> reply(req)
			{_, none} when (none == nil) -> File.read!(path) |> reply(req)
			_ -> {:shutdown, :cowboy_req.reply(401, [{"WWW-Authenticate", "Basic realm=\"myswt server\""},{"connection","close"}], "", req) |> elem(1), nil}
		end
	end
	def handle(req, _), do: {:ok, req, nil}
	def terminate(_,_,_), do: :ok
	defp reply(ans, req), do: {:ok, :cowboy_req.reply(200, [{"Content-Type","text/html; charset=utf-8"},{"connection","close"}], ans, req) |> elem(1), nil}
end