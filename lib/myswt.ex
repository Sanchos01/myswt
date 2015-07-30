defmodule Myswt do
  use Application
  use Silverb
  use Myswt.Srtucts
  require Exutils
  defmodule Console do
  	use Silverb
  	use Logex, [ttl: 100]
  end
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    :ok = :pg2.create("myswt_web_viewers")
    children = [
      # Define workers and child supervisors to be supervised
      # worker(Myswt.Worker, [arg1, arg2, arg3])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Myswt.Supervisor]
    res = Supervisor.start_link(children, opts)
	Myswt.WebServer.start
    res
  end
  def stop(reason) do
    Myswt.error("Erlang Halt becouse of reason #{inspect reason}") |> Exutils.safe
    :erlang.halt
  end

	defmodule WebServer do
		use Silverb, [
						{"@port", :application.get_env(:myswt, :server_port, nil)},
						{"@main_app", :application.get_env(:myswt, :app, nil)}
					 ]
		def start do
			true = (is_integer(@port) and is_atom(@main_app) and (@main_app != nil))
			dispatch = :cowboy_router.compile([
	                    {:_, [
	                             {"/bullet", :bullet_handler, [{:handler, Myswt.Bullet}]},
	                             {"/index.html", Myswt.ResourceLoader, ["#{Exutils.priv_dir(@main_app)}/index.html"]},
	                             {"/", Myswt.ResourceLoader, ["#{Exutils.priv_dir(@main_app)}/index.html"]},
	                             {"/[...]", :cowboy_static, {:priv_dir, @main_app, "", [{:mimetypes, :cow_mimetypes, :all}]}}
	                      ]} ])
		  	res = {:ok, _} = :cowboy.start_http(:http_test_listener, 5000, [port: @port], [env: [ dispatch: dispatch ] ])
		  	Myswt.notice "HTTP MYSWT server started at port #{@port}"
		  	res
	  	end
	end

	#
	#	public
	#

	def notice(bin) when is_binary(bin), do: send_all(%Myswt.Proto{subject: "notice", content: bin})
	def warn(bin) when is_binary(bin), do: send_all(%Myswt.Proto{subject: "warn", content: bin})
	def error(bin) when is_binary(bin), do: send_all(%Myswt.Proto{subject: "error", content: bin})

	def send_all(some = %Myswt.Proto{}) do
		mess = Myswt.encode(some)
		:pg2.get_members("myswt_web_viewers")
		|> Enum.each( &(send(&1, {:json, mess})) )
	end
	def send_all_direct(bin) when is_binary(bin) do
		:pg2.get_members("myswt_web_viewers")
		|> Enum.each( &(send(&1, {:json, bin})) )
	end

	def encode(some), do: Jazz.encode!(some)
	def decode(some), do: Jazz.decode!(some, [keys: :atoms])

	#
	#	priv
	#

	defmacro callback_module([do: body]) do
		quote location: :keep do
		  def handle_myswt(%Myswt.Proto{subject: "ping"}), do: unquote(%Myswt.Proto{subject: "pong", content: ""} |> Myswt.encode)
		  unquote(body)
		  def handle_myswt(some), do: %Myswt.Proto{subject: "error", content: "#{__MODULE__} : wrong command #{inspect some}"} |> Myswt.encode
		end
	end

end