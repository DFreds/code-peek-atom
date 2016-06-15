{CompositeDisposable, TextEditor, Emitter} = require 'atom'
{$, View, TextEditorView} = require 'atom-space-pen-views'

module.exports =
class CodePeekView extends View
  @content: ->
    @div class: 'code-peek', =>
      @header class: 'header', =>
        @span outlet: 'descriptionLabel', class: 'header-item description',
          'Code Peek'


        # @ul class: 'block', =>
        #   @li class: 'inline-block', 'One'
        #   @li class: 'inline-block', 'Two'
        # @div class: 'block', =>
        #   @div class: 'btn-group', =>
        #     @button outlet: 'saveButton', class: 'btn', =>
        #       @span class: '', 'Save'
        #     @button outlet: 'closeButton', class: 'btn', =>
        #       @span class: '', 'Close'

        # @button outlet: 'closeButton', class: 'btn', =>
        #   @span class: 'icon icon-x'

      @section class: 'input-block', =>
        # @div class: 'input-block-item input-block-item--flex editor-container', =>
        @div class: 'input-block-item input-block-item editor-container', =>
          @subview 'textEditorView', new TextEditorView()
        # @div class: 'input-block-item', =>
        #   @ol class: 'list-group', outlet: 'list'

  initialize: ->
    @subscriptions = new CompositeDisposable

    @text = null
    @editRange = null
    @originalTextEditor = null

    @textEditor = null

    @emitter = new Emitter

    # @saveButton.on 'click', @saveChanges
    # @closeButton.on 'click', @detachTextEditorView

  # Tear down any state and detach
  destroy: ->
    @subscriptions.dispose()

  # onSelectFile: (callback) ->
  #   @emitter.on 'select-file', callback

  setupForEditing: (functionInfo, originalTextEditor) ->
    @text = functionInfo.text
    @editRange = functionInfo.range
    @originalTextEditor = originalTextEditor

    @descriptionLabel.html("Code Peek <span class='subtle-info-message'>\
      #{@originalTextEditor.getPath()}</span>")

    @textEditor = @textEditorView.getModel()
    @textEditor.setGrammar(@originalTextEditor.getGrammar())

  attachTextEditorView: ->
    if not @text? or not @editRange? or not @originalTextEditor?
      throw new Error "Not all parameters set"

    @textEditor.setText(@text)

  detachTextEditorView: () =>
    @saveChanges()
    @textEditor = null

  addFiles: (filesToAdd) =>
    # $(@list).empty()
    # for file in filesToAdd
    #   fileName = file.filePath.replace(/^.*[\\\/]/, '')
    #
    #   listElement = $("<li>#{fileName}</li>").addClass("test-class")
    #   # listElement.click =>
    #   #   @emitter.emit 'select-file', file
    #   # listElement = document.createElement('li')
    #   # #listElement.setAttribute("id", @items.length - 1)
    #   # listElement.textContent = fileName
    #   # listElement.classList.add("test-class")
    #
    #   @list.append(listElement)

  saveChanges: =>
    if @textEditor? and @originalTextEditor?
      newText = @textEditor.getText()

      @originalTextEditor.setTextInBufferRange(@editRange, newText)
      @originalTextEditor.save()
