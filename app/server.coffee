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
  console.log "Grabbing client callback URL " + clientCallbackURL
  parsedClientCallbackURL = url.parse clientCallbackURL

  console.log parsedClientCallbackURL
  http.request({host: parsedClientCallbackURL.host, path: parsedClientCallbackURL.path, method: "GET"}, (clientResponse) ->
    console.log "Test"
    console.log clientResponse

    clientHash = crypto.createHash('sha1').update(clientCallbackURL).digest("hex")
    console.log "Registered " + clientCallbackURL + " as client " + clientHash

    response =
      challenge: clientHash
      verifyToken: verifyToken
      callbackURL: clientCallbackURL

    res.jsonp response
  ).on "error", (error) ->
    res.jsonp
      error: error.message

# Lists out all clients waiting for updated content
server.get "/webhook/clients.json", (req, res) ->
  res.send "Clients"

server.listen 8000
console.log "Ready for requests"
