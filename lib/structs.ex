defmodule Myswt.Srtucts do
	use Silverb
	defmacro __using__(_) do
		quote location: :keep do
			use Hashex, [
							__MODULE__.Proto
						]
			defmodule Proto do
				defstruct 	subject: "error",
							content: nil
			end
		end
	end
end