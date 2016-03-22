var app = require('../../../server/server');
var chai = require('chai');
var sinonChai = require('sinon-chai');

global._ = require('lodash');
global.should = chai.should();
global.assert = chai.assert
global.sinon = require('sinon');
global.using = require('./data-provider');

chai.use(sinonChai);
