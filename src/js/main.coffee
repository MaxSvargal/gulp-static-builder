module = require './module'

class App
  constructor: ->
    console.log module.get()

new App