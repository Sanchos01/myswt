defmodule Myswt.Example do
	use Silverb
	defmacro __using__(_) do
		quote location: :keep do
			defp handle_myswt(%Myswt.Proto{subject: "foo", content: num}) when is_number(num) do
				%Myswt.Proto{subject: "foo", content: "sin(#{num}) = #{:math.sin(num)}"} |> Myswt.encode
			end
			defp handle_myswt(%Myswt.Proto{subject: "bar", content: bin}) when is_binary(bin) do
				IO.puts "#{__MODULE__} : message bar from myswt , content \"#{bin}\"."
				%Myswt.Proto{subject: "notice", content: "OK, bro. Look message in server's console."} |> Myswt.encode
			end
		end
	end
end