mongoose = require 'mongoose'
express = require 'express'
crypto = require 'crypto'
http = require 'http'
url = require 'url'

server = express()

mongoose.connect "mongodb://localhost/webhooker"

Client = mongoose.model 'Client', mongoose.Schema
  url: String
  challenge: String
  verifyToken: String

# Used to register URLs to ping back when updates have occured.
server.get "/webhook/register.json[p]?", (req, res) ->
  clientCallbackURL = req.query.clientCallbackURL
  verifyToken = req.query.verifyToken

  unless clientCallbackURL? and verifyToken?
    return res.jsonp
      error: "A clientCallbackURL and a verifyToken parameter are required in order to register a new subscription."

  # Check if I can reach the URL
  clientHash = crypto.createHash('sha1').update(clientCallbackURL).digest("hex")
  console.log "Grabbing client callback URL " + clientCallbackURL + " with a challenge of " + clientHash
  parsedClientCallbackURL = url.parse clientCallbackURL, true

  query = parsedClientCallbackURL.query
  query.challenge = clientHash

  params = []
  for k, v of query
    params.push [k, v].join "="

  adjustedPath = parsedClientCallbackURL.pathname + "?" + params.join("&")

  parsedURL = parsedClientCallbackURL.protocol + "//" + parsedClientCallbackURL.host + adjustedPath
  console.log "Using URL of " + parsedURL

  httpRequest = http.get parsedClientCallbackURL.protocol + "//" + parsedClientCallbackURL.host + adjustedPath, (clientResponse) ->
    console.log clientResponse

    responseData = []
    clientResponse.on "data", (chunk) ->
      responseData.push chunk
      console.log chunk

    clientResponse.on "close", ->
      console.log "Connection closed by peer"
      res.jsonp
        error: "Connection closed by peer"

    clientResponse.on "end", ->
      responseHash = responseData.join("")
      console.log "A body was returned consisting of the following."
      console.log responseHash

      if responseHash is clientHash
        console.log "Registered " + clientCallbackURL + " as client " + clientHash

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
server.get "/webhook/exampleClient", (req, res) ->
  challenge = req.query.challenge
  return res.send challenge if challenge?

  res.send req.query.update

server.listen 8000
console.log "Ready for requests"
