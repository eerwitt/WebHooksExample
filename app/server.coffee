express = require 'express'
crypto = require 'crypto'
http = require 'http'
url = require 'url'

server = express()
server.use express.bodyParser()

Client = require './models/client'

# Used to register URLs to ping back when updates have occured.
server.get "/webhook/register.json[p]?", (req, res) ->
  clientCallbackURL = req.query.clientCallbackURL
  verifyToken = req.query.verifyToken

  unless clientCallbackURL? and verifyToken?
    return res.jsonp
      error: "A clientCallbackURL and a verifyToken parameter are required in order to register a new subscription."

  # This hash could be made by any route, this one isn't good because someone can easily guess it. Just a hash is required to verify connections.
  clientHash = crypto.createHash('sha1').update(clientCallbackURL).digest("hex")

  console.log "Grabbing client callback URL " + clientCallbackURL + " with a challenge of " + clientHash
  parsedClientCallbackURL = url.parse clientCallbackURL, true

  # Once we have a challenge hash we add it to the query string to send to the callback
  query = parsedClientCallbackURL.query
  query.challenge = clientHash

  params = []
  for k, v of query
    params.push [k, v].join "="

  adjustedPath = parsedClientCallbackURL.pathname + "?" + params.join("&")

  parsedURL = parsedClientCallbackURL.protocol + "//" + parsedClientCallbackURL.host + adjustedPath
  console.log "Using URL of " + parsedURL

  # Now to check if we can reach the URL
  httpRequest = http.get parsedURL, (clientResponse) ->
    responseData = []
    clientResponse.on "data", (chunk) ->
      responseData.push chunk

    clientResponse.on "close", ->
      console.log "Connection closed by peer"
      res.jsonp
        error: "Connection closed by peer"

    clientResponse.on "end", ->
      responseHash = responseData.join("")
      console.log "A body was returned consisting of the following."
      console.log responseHash

      # The response has to be the same as the challenge sent to the client
      if responseHash is clientHash
        console.log "Registered " + clientCallbackURL + " as client " + clientHash

        # If it matches we add a new client with the url set to be the callback
        client = new Client url: clientCallbackURL, verifyToken: verifyToken, challenge: clientHash
        client.save (error) ->
          if error?
            console.log "Error creating a client: " + error

            res.jsonp
              error: "Error creating a client: " + error
          else
            console.log "Created client connection"

            res.jsonp
              challenge: clientHash
              verifyToken: verifyToken
              callbackURL: clientCallbackURL
      else
        res.jsonp
          error: "Expected a challenge to be echo'd back"

  httpRequest.on "error", (error) ->
    res.jsonp
      error: error.message

# Lists out all clients waiting for updated content
server.get "/webhook/clients.json", (req, res) ->
  Client.find {}, (error, docs) ->
    if error?
      res.jsonp
        error: "Can't find clients: " + error
    else
      res.jsonp
        results: docs

# An example client responding to webhooks
#  This is the get route which has to respond with the challenge
server.get "/webhook/exampleClient", (req, res) ->
  challenge = req.query.challenge

  if challenge?
    res.send challenge
  else
    res.send "No challenge sent in"

#  This is the post route for updates as they come in
server.post "/webhook/exampleClient", (req, res) ->
  console.log "Update came in"
  res.send "Update found"

server.listen 8000
console.log "Ready for requests"
