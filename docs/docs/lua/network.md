# Network API

### Fetch

#### fetch(url, options)

Makes HTTP requests with full control over method, headers, and body.

```lua
-- Simple GET request
local response = fetch('https://api.example.com/data')

-- POST request with data
local response = fetch('https://api.example.com/users', {
    method = 'POST',
    headers = {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = 'Bearer token123'
    },
    body = JSON.stringify({
        name = 'John Doe',
        email = 'john@example.com'
    })
})

-- Check response
if response:ok() then
    local data = response:json()  -- Parse JSON response
    local text = response:text()  -- Get as text
    
    trace.log('Status: ' .. response.status)
    trace.log('Status Text: ' .. response.statusText)
    
    -- Access headers
    local contentType = response.headers['content-type']
else
    trace.log('Request failed with status: ' .. response.status)
end
```

**Supported Methods:** `GET`, `POST`, `PUT`, `DELETE`, `HEAD`, `OPTIONS`, `PATCH`

**Relative URLs** are automatically resolved to the current domain with `gurt://` protocol.

## WebSocket API

Real-time communication with WebSocket servers.

```lua
local ws = WebSocket.new('ws://localhost:8080/chat')

ws:on('open', function()
    trace.log('WebSocket connected')
    ws:send('Hello server!')
end)

ws:on('message', function(message)
    trace.log('Received message: ' .. message.data)
end)

ws:on('close', function()
    trace.log('WebSocket closed.')
end)

ws:on('error', function(error)
    trace.log('WebSocket error: ' .. error.message)
end)

ws:send('Hello from client!')
ws:send(JSON.stringify({ type = 'chat', message = 'Hello!' }))

ws:close()
```

## URL API

URL encoding and decoding utilities for handling special characters in URLs.

### urlEncode(string)

Encodes a string for safe use in URLs by converting special characters to percent-encoded format.

```lua
local encoded = urlEncode('hello world!')
trace.log(encoded) -- hello%20world%21

local params = urlEncode('name=John Doe&age=30')
trace.log(params) -- name%3DJohn%20Doe%26age%3D30

-- Building query strings
local searchTerm = 'cats & dogs'
local url = 'gurt://search.com/api?q=' .. urlEncode(searchTerm)
trace.log(url) -- gurt://search.com/api?q=cats%20%26%20dogs
```

### urlDecode(string)

Decodes a percent-encoded URL string back to its original form.

```lua
local decoded = urlDecode('hello%20world%21')
trace.log(decoded) -- hello world!

local params = urlDecode('name%3DJohn%20Doe%26age%3D30')
trace.log(params) -- name=John Doe&age=30

local queryParam = 'cats%20%26%20dogs'
local searchTerm = urlDecode(queryParam)
trace.log(searchTerm) -- cats & dogs
```

## JSON API

### JSON.stringify(data)

Converts Lua data to JSON string.

```lua
local data = {
    name = 'Alice',
    age = 30,
    hobbies = {'reading', 'coding'},
    active = true
}

local jsonString = JSON.stringify(data)
trace.log(jsonString)  -- {"name":"Alice","age":30,"hobbies":["reading","coding"],"active":true}
```

### JSON.parse(jsonString)

Parses JSON string to Lua data.

```lua
local jsonString = '{"name":"Bob","score":95.5}'
local data, error = JSON.parse(jsonString)

if data then
    trace.log('Name: ' .. data.name)
    trace.log('Score: ' .. data.score)
else
    trace.log('Parse error: ' .. error)
end
```
