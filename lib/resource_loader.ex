defmodule Myswt.ResourceLoader do
	use Silverb, [{"@basic_auth", :application.get_env(:myswt, :basic_auth, nil)},{"@main_app", :application.get_env(:myswt, :app, nil)}]
	require Record
	Record.defrecord :http_req, [socket: :undefined, transport: :undefined, connection: :keepalive, pid: :undefined, method: "GET", version: :"HTTP/1.1", peer: :undefined, host: :undefined, host_info: :undefined, port: :undefined, path: :undefined, path_info: :undefined, qs: :undefined, qs_vals: :undefined, bindings: :undefined, headers: [], p_headers: [], cookies: :undefined, meta: [], body_state: :waiting, multipart: :undefined, buffer: "", resp_compress: false, resp_state: :waiting, resp_headers: [], resp_body: "", onresponse: :undefined]
	def init(_, req, [path]) when is_binary(path) do
		case auth?(req) do
			{true, req} -> {:ok, :cowboy_req.reply(200, [{"Content-Type","text/html; charset=utf-8"},{"connection","close"}], File.read!(path), req) |> elem(1), nil}
			{false, req} -> {:shutdown, :cowboy_req.reply(401, [{"WWW-Authenticate", "Basic realm=\"myswt server\""},{"connection","close"}], "", req) |> elem(1), nil}
		end
	end
	def init(_, req = http_req(path: path), [nil]) do
		case auth?(req) do
			{true, req} -> 
				filename = "#{Exutils.priv_dir(@main_app)}#{path}"
				case File.exists?(filename) do
					true -> {:ok, :cowboy_req.reply(200, [{"Content-Type",:mimetypes.filename(path)},{"connection","close"}], File.read!(filename), req) |> elem(1), nil}
					false -> {:ok, :cowboy_req.reply(404, [{"connection","close"}], "", req) |> elem(1), nil}
				end	
			{false, req} -> {:shutdown, :cowboy_req.reply(401, [{"WWW-Authenticate", "Basic realm=\"myswt server\""},{"connection","close"}], "", req) |> elem(1), nil}
		end
	end
	def handle(req, _), do: {:ok, req, nil}
	def terminate(_,_,_), do: :ok

	
	defp auth?(req) do
		case {:cowboy_req.parse_header("authorization", req), @basic_auth} do
			{{:ok, {"basic",{login,password}}, req}, %{login: login, password: password}} -> {true, req}
			{_, none} when (none == nil) -> {true, req}
			_ -> {false, req}
		end
	end

end