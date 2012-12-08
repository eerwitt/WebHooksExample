mongoose = require 'mongoose'

# This is a simple client model holding the most important part, a URL which
# will get pinged back to upon any updates.
Client = mongoose.model 'Client', mongoose.Schema
  url: String
  challenge: String
  verifyToken: String

# I wouldn't usually do this, just for example
mongoose.connect "mongodb://localhost/webhooker"
module.exports = Client
