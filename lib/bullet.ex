
defmodule Myswt.Bullet do

  @pong %Myswt.Proto{subject: "pong", content: ""} |> Myswt.encode

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
        %{subject: subject, content: content} -> handle_message_from_client(%Myswt.Proto{subject: subject, content: content})
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

  #############################################
  ### private handlers for mess from client ###
  #############################################

  defp handle_message_from_client(%Myswt.Proto{subject: "ping"}), do: @pong
  #
  #	TODO
  #
  defp handle_message_from_client(some), do: %Myswt.Proto{subject: "error", content: "#{__MODULE__} : wrong command #{inspect some}"} |> Myswt.encode

end