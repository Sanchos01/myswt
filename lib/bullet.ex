
defmodule Myswt.Bullet do

  @callback_module :application.get_env(:myswt, :callback_module, nil)

  ########################
  ### public callbacks ###
  ########################

  def init(_Transport, req, _Opts, _Active) do
    :pg2.join "web_viewers", self
    IO.puts "Bullet handler: init"
    {:ok, req, :undefined_state}
  end
  def stream(data, req, state) do
    {
      :reply,
      case Myswt.decode(data) do
        %{subject: subject, content: content} -> @callback_module.handle_myswt(%Myswt.Proto{subject: subject, content: content})
        err -> %Myswt.Proto{content: "#{__MODULE__} : Error on protocol from client. Content: #{inspect err}"} |> Myswt.encode
      end,
      req,
      state
    }
  end
  def info({:json, cont}, req, state) do
    {
      :reply,
      cont,
      req,
      state
    }
  end
  def info(info, req, state) do
    Myswt.error "#{__MODULE__} : unexpected info #{inspect info}"
    {:ok, req, state}
  end
  def terminate(_req, _state) do
    :pg2.leave "web_viewers", self
  end

end