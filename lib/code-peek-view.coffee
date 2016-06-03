{Range, Point, CompositeDisposable} = require 'atom'

module.exports =
class CodePeekView
  constructor: ->
    #TODO remove this later
    @element = document.createElement('div')

    @file = null
    @text = null
    @editRange = null

    @textEditorView = document.createElement('atom-text-editor')
    @textEditor = @textEditorView.getModel()

    @grammars = atom.grammars

    @subscriptions = new CompositeDisposable

    # Create root element
    # @element = document.createElement('div')
    # @element.classList.add('code-peek')
    #
    # # Create message element
    # message = document.createElement('div')
    # message.textContent = "The CodePeek package is Alive! It's ALIVE!"
    # message.classList.add('message')
    # @element.appendChild(message)

  # Tear down any state and detach
  destroy: ->
    @subscriptions.dispose()

  setFile: (file) ->
    @file = file

  setText: (text) ->
    @text = text

  setGrammar: ->
    if @file is null or @test is null
      throw new Error "Text and file must be set"
    @textEditor.setGrammar(atom.grammars.selectGrammar(@file.getPath(), @text))

  setEditRange: (range) ->
    @editRange = range

  # TODO might not need to do this
  getElement: ->
    @element
