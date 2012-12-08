mongoose = require 'mongoose'

Client = mongoose.model 'Client', mongoose.Schema
  url: String
  challenge: String
  verifyToken: String

# I wouldn't usually do this, just for example
mongoose.connect "mongodb://localhost/webhooker"
module.exports = Client
