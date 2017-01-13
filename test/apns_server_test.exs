defmodule ApnsServerTest do
  use ExUnit.Case
  doctest MockPushServer

  setup do
      {:ok, %{pid:  H2Client.init_local}} 
  end

  test "APNS Success", %{pid: pid} do
    headers =  [
          {":method", "POST"},
          {"apns-id", "apns-id"},
          {":path", "/3/device/success"},
    ]
    {:ok, response} = H2Client.request(pid, headers, "payload in json")
    assert response.status == 200
  end

  test "APNS Error BadCollapseId", %{pid: pid} do
    headers =  [
          {":method", "POST"},
          {"apns-id", "toto"},
          {":path", "/3/device/CustomError=BadCollapseId"},
    ]
    {:ok, response} = H2Client.request(pid, headers, "payload in json")
    assert response.status == 400
    assert response.body == ~S{{"reason":"BadCollapseId"\}}
  end

  test "APNS Success with latency", %{pid: pid} do
    Kadabra.put pid, "/latency", "1000"
    assert_receive {:end_stream, _}, 5_000
    headers =  [
          {":method", "POST"},
          {"apns-id", "toto"},
          {":path", "/3/device/success"},
    ]
    {time, {:ok, response}} = :timer.tc(fn-> H2Client.request(pid, headers, "payload in json") end )
    assert time >= 1000
    assert response.status == 200
    Kadabra.put pid, "/latency", "0"
  end
end
