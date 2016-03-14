require '../server/server' # Loads the server so that loopback.getModel is available
chai = require 'chai'
sinonChai = require 'sinon-chai'

chai.use sinonChai
