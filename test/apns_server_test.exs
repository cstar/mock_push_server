defmodule ApnsServerTest do
  use ExUnit.Case
  doctest MockPushServer

  setup do
      {:ok, %{pid:  H2Client.init_local}} 
  end

  test "APNS Success", %{pid: pid} do
    headers =  [
          {":method", "POST"},
          {"apns-id", "toto"},
          {":path", "/3/device/toto"},
    ]
    response = H2Client.request(pid, headers, "toto")
    assert response.code == 200
  end
end
