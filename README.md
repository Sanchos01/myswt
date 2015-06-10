Myswt
=====

WARNING! External deps !!!
```
git
npm
bower
brunch
```

To use it, write myswt to deps of your application, write config
```
config :myswt, 
	app: :great_web_application, 
	server_port: 8081, 
	callback_module: GreatWebApplication.Callbacks
```

and then execute these commands. It creates in priv/megaweb dir skeleton of client-side code of your great_web_application.
```
mix deps.get && mix deps.compile
mix myswt.init
mix myswt.build # or sudo mix myswt.build
```

Write module GreatWebApplication.Callbacks, something like this. Yeah, there is only one &callback_module/1 macro. Inside are your own multiple clauses of only one function &handle_myswt/1. 

- subject: command, binary ("ping" and "pong" commands are reserved, not use them!!!)
- content: some jsonable erlang term

There are only handlers for messages from client... They all must return binaries.
```
defmodule GreatWebApplication.Callbacks do
	require Myswt
	Myswt.callback_module do
		def handle_myswt(%Myswt.Proto{subject: "foo", content: num}) when is_number(num) do
			%Myswt.Proto{subject: "foo", content: "sin(#{num}) = #{:math.sin(num)}"} |> Myswt.encode
		end
		def handle_myswt(%Myswt.Proto{subject: "bar", content: bin}) when is_binary(bin) do
			IO.puts "#{__MODULE__} : message bar from myswt , content \"#{bin}\"."
			%Myswt.Proto{subject: "notice", content: "OK, bro. Look message in server's console."} |> Myswt.encode
		end
	end
end
```

Now you can run your app and see hello world in http://localhost:8081
```
iex -S mix
2015-05-07 02:23:08.291 [debug] HTTP MYSWT server started at port 8081
Interactive Elixir (1.0.3) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

Next, write your awesome web application using brunch. Skeleton is in ./priv/megaweb path. Use twitter bootstrap, angularjs, jquery, jade, jreact, sass.. any you want. Erlang cowboy bullet websockets are already included. Handlers in client side are similar server-side handlers. It will build your client-side code
```
mix myswt.build # or sudo mix myswt.build
```

Well, your also can use these public functions in any places of your server-side code, to send something to clients..
```
&Myswt.notice/1
&Myswt.warn/1
&Myswt.error/1

&Myswt.encode/1

&Myswt.send_all/1
&Myswt.send_all_direct/1
```

Examples
```
Myswt.notice "hello, world!"
Myswt.send_all %Myswt.Proto{subject: "foo", content: 123}
Myswt.send_all_direct Myswt.encode(%Myswt.Proto{subject: "foo", content: 123})
```