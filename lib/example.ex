defmodule Myswt.Example do
	use Silverb
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