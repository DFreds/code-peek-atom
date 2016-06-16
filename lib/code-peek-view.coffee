{CompositeDisposable, TextEditor, Emitter} = require 'atom'
{$, View, TextEditorView} = require 'atom-space-pen-views'

module.exports =
class CodePeekView extends View
  @content: ->
    peekEditor = atom.workspace.buildTextEditor()
    @div class: 'code-peek', =>
      @header class: 'header', =>
        @span outlet: 'descriptionLabel', class: 'header-item description',
          'Code Peek'

        @span class: "header-item pull-right description", =>
          @span outlet: 'closeHelpLabel'
          @span outlet: 'closeIcon', class: 'icon icon-x close-icon'

      @section class: 'input-block', =>
        # @div class:
        #'input-block-item input-block-item--flex editor-container', =>
        @div class: 'input-block-item input-block-item editor-container', =>
          @subview 'textEditorView', new TextEditorView(editor: peekEditor)
        # @div class: 'input-block-item', =>
        #   @ol class: 'list-group', outlet: 'list'

  initialize: ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.tooltips.add @closeIcon,
      title: "Close without saving"

    @text = null
    @editRange = null
    @originalTextEditor = null

    @textEditor = null

    @emitter = new Emitter

    @closeIcon.on 'click', =>
      @emitter.emit 'close-icon-clicked', false

    # @saveButton.on 'click', @saveChanges
    # @closeButton.on 'click', @detachTextEditorView

  # Tear down any state and detach
  destroy: ->
    @subscriptions.dispose()

  # onSelectFile: (callback) ->
  #   @emitter.on 'select-file', callback

  onCloseIconClicked: (callback) ->
    @emitter.on 'close-icon-clicked', callback

  setupForEditing: (functionInfo, originalTextEditor) ->
    @text = functionInfo.text
    @editRange = functionInfo.range
    @originalTextEditor = originalTextEditor

    @descriptionLabel.html("Code Peek <span class='subtle-info-message'>\
      #{@originalTextEditor.getPath()}</span>")

    closeKeyMap = atom.keymaps.findKeyBindings({
      command: 'code-peek:toggleCodePeekOff'
    })
    @closeHelpLabel.html("<span class='subtle-info-message'>\
      Save changes and close this panel using <span class='highlight'>\
      #{closeKeyMap[0].keystrokes}</span></span>")

    @textEditor = @textEditorView.getModel()
    @textEditor.setGrammar(@originalTextEditor.getGrammar())

  attachTextEditorView: ->
    if not @text? or not @editRange? or not @originalTextEditor?
      throw new Error "Not all parameters set"

    @textEditor.setText(@text)

  detachTextEditorView: () =>
    @textEditor = null

  # addFiles: (filesToAdd) =>
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
