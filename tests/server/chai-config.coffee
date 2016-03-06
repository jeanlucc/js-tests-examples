app = require '../../server/server'
chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
sinonChai = require 'sinon-chai'

chai.use chaiAsPromised
chai.use sinonChai
