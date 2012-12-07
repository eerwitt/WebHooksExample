express = require 'express'
crypto = require 'crypto'
http = require 'http'
url = require 'url'

server = express()

# Used to register URLs to ping back when updates have occured.
server.get "/webhook/register.json[p]?", (req, res) ->
  clientCallbackURL = req.query.clientCallbackURL
  verifyToken = req.query.verifyToken

  unless clientCallbackURL? and verifyToken?
    res.jsonp
      error: "A clientCallbackURL and a verifyToken parameter are required in order to register a new subscription."
    return

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
  console.log "Using adjusted path of " + adjustedPath

  httpRequest = http.request host: parsedClientCallbackURL.host, path: adjustedPath, method: "GET", (clientResponse) ->
    responseData = null
    clientResponse.on "data", (chunk) ->
      responseData << chunk

    clientResponse.on "close", ->
      console.log "Connection closed by peer"
      res.jsonp
        error: "Connection closed by peer"

    clientResponse.on "end", ->
      console.log responseData

      if responseData is clientHash
        console.log "Registered " + clientCallbackURL + " as client " + clientHash

        response =
          challenge: clientHash
          verifyToken: verifyToken
          callbackURL: clientCallbackURL

        res.jsonp response
      else
        res.jsonp
          error: "Expected a challenge to be echo'd back"

  httpRequest.on "error", (error) ->
    res.jsonp
      error: error.message

# Lists out all clients waiting for updated content
server.get "/webhook/clients.json", (req, res) ->
  res.send "Clients"

server.listen 8000
console.log "Ready for requests"
