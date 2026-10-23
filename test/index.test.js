const test = require('node:test');
const assert = require('node:assert');
const { addTax } = require('../src/index.js');
test('adds 16 percent tax', () => assert.strictEqual(addTax(100, 0.16), 116));
