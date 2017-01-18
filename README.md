# MockPushServer

Simulates APNS and FCM platforms. Used for testing API failure modes. Highly concurrent, is to be used for stress-testing components without undue load on real platforms.

Supports HTTP/1.1 and HTTP2

## FCM (formerly known as GCM)
You can customize the response by setting the registration value to an error code or to "update:new_registration_id"

Error codes are 

```
error:MissingRegistration
error:InvalidRegistration
error:NotRegistered
error:InvalidPackageName
error:MismatchSenderId
error:MessageTooBig
error:InvalidDataKey
error:InvalidTtl
error:Unavailable
error:InternalServerError
error:DeviceMessageRate 
error:TopicsMessageRateExceeded
```


### FCM Examples

#### Success with registration update
```bash

curl -i -k -XPOST -H "Content-Type: application/json" -H "Authorization: key=AIzaSyZ-1u" -d @../mock_push_server/priv/sample-multiple.json https://localhost:8443/fcm/send
# HTTP/1.1 200 OK
# content-length: 255
# content-type: application/json
# date: Wed, 18 Jan 2017 10:10:26 GMT
# server: Cowboy
#
# {"success":2,"results":[{"message_id":"2c6ccfe0-9064-49eb-acff-55e98751001b"},{"registration_id":":registration_id2","message_id":"2c6ccfe0-9064-49eb-acff-55e98751001b"}],"multicast_id":"3148d4fb-4309-45ca-9eb2-20a819738d87","failure":0,"canonical_ids":1}

```

#### some failures

```bash
curl -i -k -XPOST -H "Content-Type: application/json" -H "Authorization: key=AIzaSyZ-1u" -d @../mock_push_server/priv/sample-failures.json

# HTTP/1.1 200 OK
# content-length: 219
# content-type: application/json
# date: Wed, 18 Jan 2017 11:15:00 GMT
# server: Cowboy
#
# {"success":1,"results":[{"error":"NotRegistered"},{"error":"DeviceMessageRate"},{"message_id":"d9db8abb-3b1a-4e29-a750-55901d0534f4"}],"multicast_id":"6964845d-8131-4694-b572-d10b682cd682","failure":2,"canonical_ids":0
```

## APNS

> Note : For best effect, this API should only be accessed through HTTP2, just like the real one.

If the token is set to one of these values, this error (with appropriate HTTP return status) will be returned by the API.

No authentication is performed.

```
error:BadCollapseId
error:BadDeviceToken
error:BadExpirationDate
error:BadMessageId
error:BadPriority
error:BadTopic
error:DeviceTokenNotForTopic
error:DuplicateHeaders
error:IdleTimeout
error:MissingDeviceToken
error:MissingTopic
error:PayloadEmpty
error:TopicDisallowed
error:BadCertificate
error:BadCertificateEnvironment
error:ExpiredProviderToken
error:Forbidden
error:InvalidProviderToken
error:MissingProviderToken
error:BadPath
error:MethodNotAllowed
error:Unregistered
error:PayloadTooLarge
error:TooManyProviderTokenUpdates
error:TooManyRequests
error:InternalServerError
error:ServiceUnavailable
error:Shutdown
```

### APNS Examples

The `H2Client` module tests with HTTP2

```elixir

H2Client.init_local |> H2Client.apns_local pid
# {:ok,
#  %Kadabra.Stream{body: nil,
#   headers: [{":status", "200"}, {"apns-id", "my-topic"}, {"content-length", "0"},
#    {"content-type", "application/json"},
#    {"date", "Wed, 18 Jan 2017 11:18:19 GMT"}, {"server", "Cowboy"}], id: 1,
#   status: 200}}

H2Client.init_local |> H2Client.apns_local_error( "BadDeviceToken")
# {:ok,
# %Kadabra.Stream{body: "{\"reason\":\"BadDeviceToken\"}",
#  headers: [{":status", "400"}, {"content-length", "27"},
#   {"content-type", "application/json"},
#   {"date", "Wed, 18 Jan 2017 11:41:57 GMT"}, {"server", "Cowboy"}], id: 1,
#  status: 400}}
```

## Latency

System latency in ms can be increased by calling the `/latency` endpoint:

```bash
 curl -i -k -XPUT https://localhost:8443/latency -d "{\"gcm\": 100, \"apns\": 130}"

# HTTP/1.1 200 OK
# content-length: 25
# content-type: application/json
# date: Wed, 18 Jan 2017 11:09:38 GMT
# server: Cowboy
# 
# {"gcm": 100, "apns": 130}
```

## Installation

- `mix deps.get`
- `iex -S mix`

