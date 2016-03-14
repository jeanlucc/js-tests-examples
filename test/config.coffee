require '../server/server' # Loads the server so that loopback.getModel is available
chai = require 'chai'
sinonChai = require 'sinon-chai'

chai.use sinonChai

global.assert = require('chai').assert
global.should = chai.should()
global.sinon = require 'sinon'
global.using = require './common/utils/data-provider'
