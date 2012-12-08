querystring = require 'querystring'
request = require 'request'
url = require 'url'

Client = require './models/client'

console.log "Finding clients to send updates to"
Client.find {}, (error, docs) ->
  if error?
    console.log "Error finding clients to update: " + error
    return

  for doc in docs
    rawClientURL = doc.url

    unless rawClientURL?
      console.log "No url for given client"
      continue

    postData =
      type: "name_replaced"
      updateMark: "123"
      id: "2534"

    console.log "Posting to " + rawClientURL
    request.post rawClientURL, form: postData, (error, response, body) ->
      if error?
        console.log "Error posting to callback: " + error
      else
        console.log "Request successful"
        console.log "Body: " + body
