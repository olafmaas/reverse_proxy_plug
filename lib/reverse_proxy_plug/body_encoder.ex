defmodule ReverseProxyPlug.BodyEncoder do

  @spec encode({binary(), binary()}, map()) :: {tuple() | binary(), binary()}
  def encode({_, "multipart/" <> _subtype = type}, body_params) do
    actual_type = type |> String.split(";") |> Enum.at(0)

    {
      {
        :multipart,
        Enum.map(body_params, &encode_multipart/1)
      },
      actual_type
    }
  end

  def encode(_, body_params) do
    body = Poison.encode!(body_params)

    {body, "application/json"}
  end

  defp encode_multipart({key, %Plug.Upload{filename: filename, path: path, content_type: content_type}}) do
    {
      :file,
      path,
      {
        "form-data",
        [
          {:name, key},
          {:filename, filename},
        ]
      },
      [{"Content-Type", content_type}]
    }
  end

  defp encode_multipart(pair), do: pair
end
