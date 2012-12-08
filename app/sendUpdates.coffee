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
      console.log error, response, body
    
#    requestOptions =
#      host: clientURL.hostname
#      port: clientURL.port
#      path: clientURL.path
#      method: 'POST'
#      headers:
#        'Content-Type': 'application/x-www-form-urlencoded'
#        'Content-Length': postData.length
#
#    httpRequest = http.request requestOptions, (res) ->
#      res.setEncoding 'utf8'
#      console.log "Got response"
#
#      postResponse = []
#      res.on 'data', (chunk) ->
#        postResponse.push chunk
#
#      res.on 'end', ->
#        console.log "Had response of " + postResponse.join("")
#
#    httpRequest.on "error", (error) ->
#      console.log "Error returned from request " + error
#
#    httpRequest.write querystring.stringify(postData)
#    httpRequest.end()
