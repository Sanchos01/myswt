defmodule Myswt do
  @create_priv Myswt.ClientCallbacks.create_priv
  use Application
  use Myswt.Srtucts
  require Logger
  require Exutils
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    :ok = :pg2.create("myswt_web_viewers")
	compile_iced
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
    Myswt.error(:error, "Erlang Halt becouse of reason #{inspect reason}") |> Exutils.safe
    :erlang.halt
  end

	defmodule WebServer do
		@port :application.get_env(:myswt, :server_port, nil)
		def start do
			dispatch = :cowboy_router.compile([
	                    {:_, [
	                             {"/bullet", :bullet_handler, [{:handler, Myswt.Bullet}]},
	                             {"/", :cowboy_static, {:priv_file, :myswt, "index.html"}},
	                             {"/[...]", :cowboy_static, {:priv_dir, :myswt, "", [{:mimetypes, :cow_mimetypes, :all}]}}
	                      ]} ])
		  	res = {:ok, _} = :cowboy.start_http(:http_test_listener, 5000, [port: @port], [env: [ dispatch: dispatch ] ])
		  	Myswt.notice "HTTP MYSWT server started at port #{@port}"
		  	res
	  	end
	end

	#
	#	public
	#

	def notice(bin) when is_binary(bin) do
		send_all(%Myswt.Proto{subject: "notice", content: bin})
		Logger.debug bin
	end
	def warn(bin) when is_binary(bin) do
		send_all(%Myswt.Proto{subject: "warn", content: bin})
		Logger.warn bin
	end
	def error(bin) when is_binary(bin) do
		send_all(%Myswt.Proto{subject: "error", content: bin})
		Logger.error bin
	end	

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

	defp compile_iced do
		res = :os.cmd("cd #{Exutils.priv_dir(:myswt)}/iced && iced -c ./scripts.iced && mv ./scripts.js ../js/scripts.js" |> String.to_char_list)
		Myswt.notice "#{__MODULE__} : iced compilation result : #{inspect res}"
		File.read!( Exutils.priv_dir(:myswt)<>"/js/scripts.js" )
	end

end