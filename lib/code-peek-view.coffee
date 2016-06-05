{CompositeDisposable, TextEditor} = require 'atom'
{View, TextEditorView} = require 'atom-space-pen-views'

module.exports =
class CodePeekView extends View
  @content: ->
    @div class: 'code-peek', =>
      @header class: 'header', =>
        @span outlet: 'descriptionLabel', class: 'header-item description',
          'Code Peek'

        # @div class: 'block', =>
        #   @div class: 'btn-group', =>
        #     @button outlet: 'saveButton', class: 'btn', =>
        #       @span class: '', 'Save'
        #     @button outlet: 'closeButton', class: 'btn', =>
        #       @span class: '', 'Close'

        # @button outlet: 'closeButton', class: 'btn', =>
        #   @span class: 'icon icon-x'
      @div =>
        @subview 'textEditorView', new TextEditorView()

  initialize: ->
    @subscriptions = new CompositeDisposable

    @text = null
    @editRange = null
    @originalTextEditor = null

    @grammarReg = atom.grammars
    @grammar = null

    @textEditor = null

    # @saveButton.on 'click', @saveChanges
    # @closeButton.on 'click', @detachTextEditorView

  # Tear down any state and detach
  destroy: ->
    @subscriptions.dispose()
    @element.remove()

  setupForEditing: (functionInfo, originalTextEditor) ->
    @text = functionInfo.text
    @editRange = functionInfo.range
    @originalTextEditor = originalTextEditor

    @grammar = @grammarReg.selectGrammar(@originalTextEditor.getPath(), @text)
    @descriptionLabel.html("Code Peek <span class='subtle-info-message'>\
      #{@originalTextEditor.getPath()}</span>")

    @textEditor = @textEditorView.getModel()
    @textEditor.setGrammar(@grammar)

  attachTextEditorView: ->
    if not @text? or not @editRange? or not @originalTextEditor?
      throw new Error "Not all parameters set"

    @textEditor.setText(@text)

  detachTextEditorView: () =>
    @saveChanges()
    @textEditor = null

  saveChanges: =>
    newText = @textEditor.getText()

    @originalTextEditor.setTextInBufferRange(@editRange, newText)
    @originalTextEditor.save()
