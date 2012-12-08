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

    # This is an example update, to be replaced by whatever meta data BC is sending in.
    #  type: The type of update which has happened
    #  updateMark: Some relation to show which point this update is, possibly a sequence so we know if updates are missed
    #  id: The id of the object to go and fetch
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
