#WebHooks Example

A basic WebHooks API for registering clients to post updated data to.

## Process Overview
1. There is a server waiting for requests expecting a client URL to post updates to.
2. The server is hit with a request asking to add a URL to it's list of URLs to post updates to.
	1. The server hits the requested client URL supplying a challenge hash (could be anything).
	2. If the client URL responds with the same challenge hash it is added to the list of clients to send updates to.
3. Every time an update occurs it is sent to every client URL signed up waiting for updates.
4. The update contains a unique ID to request from the API in order to get it's updated content.
5. Client can now ask for exactly the IDs which have been updated.

## Installation and Starting

Uses node and coffeescript.

```bash

	npm install
	coffee app/server

```

## Registering a Client

To register a client, supply a callback URL and hit the following URL.

http://localhost:8000/webhook/register.json?clientCallbackURL=callback URL&verifyToken=123

For example.

```bash

	curl 'http://localhost:8000/webhook/register.json?clientCallbackURL=http%3A%2%2Flocalhost%3A8000%2Fwebhook%2FexampleClient&verifyToken=123'
	{
  		"challenge": "73451672ac5db9431e5d28d330603c797590b31d",
  		"verifyToken": "123",
  		"callbackURL": "http://localhost:8000/webhook/exampleClient"
	}

```

This will make a request to the callback URL expecting it to echo the requested challenge.

## List Clients

```bash

	curl http://localhost:8000/webhook/clients.json
	
```

## Send Updates

Now that there are clients available you can send updates to each one.

```bash

	coffee app/sendUpdates

```