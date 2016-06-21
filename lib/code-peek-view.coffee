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
          @span outlet: 'checkIcon', class: 'icon icon-check check-icon'
          @span outlet: 'codeIcon', class: 'icon icon-code code-icon'
          @span outlet: 'closeIcon', class: 'icon icon-x close-icon'

      @section class: 'input-block', =>
        @div class: 'input-block-item--flex editor-container', =>
          @subview 'textEditorView', new TextEditorView(editor: peekEditor)
        @div class: 'input-block-item', =>
          @span class: 'matching-files-label', 'Matching Files'
          @ol class: 'list-group matching-files-list', outlet: 'list'

  initialize: ->
    @subscriptions = new CompositeDisposable

    saveAndCloseKeymap = atom.keymaps.findKeyBindings({
      command: 'code-peek:toggleCodePeekOff'
    })

    @subscriptions.add atom.tooltips.add @checkIcon,
      title: "Save and close (#{saveAndCloseKeymap[0].keystrokes})"

    @subscriptions.add atom.tooltips.add @codeIcon,
      title: "See entire file"

    @subscriptions.add atom.tooltips.add @closeIcon,
      title: "Close without saving"

    @text = null
    @editRange = null
    @originalTextEditor = null

    @textEditor = null

    @emitter = new Emitter

    @checkIcon.on 'click', =>
      @emitter.emit 'check-icon-clicked', true
    @codeIcon.on 'click', =>
      fileInfo =
        filePath: @originalTextEditor.getPath()
        range: @editRange
      @emitter.emit 'code-icon-clicked', fileInfo
    @closeIcon.on 'click', =>
      @emitter.emit 'close-icon-clicked', false

  # Tear down any state and detach
  destroy: ->
    @subscriptions.dispose()

  onCheckIconClicked: (callback) ->
    @emitter.on 'check-icon-clicked', callback

  onCodeIconClicked: (callback) ->
    @emitter.on 'code-icon-clicked', callback

  onCloseIconClicked: (callback) ->
    @emitter.on 'close-icon-clicked', callback

  onSelectFile: (callback) ->
    @emitter.on 'select-file', callback

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
    @textEditor.setCursorBufferPosition([0, 0])
    @textEditor.scrollToCursorPosition()

    height = atom.config.get("code-peek.maxCodePeekHeight")
    $('.code-peek').css("max-height", height + "px")

  detachTextEditorView: () =>
    @textEditor = null

  addFiles: (filesToAdd) =>
    $(@list).empty()
    @list.off 'click'
    for file, index in filesToAdd
      fileName = file.filePath.replace(/^.*[\\\/]/, '')

      listElement = $("<li id='#{index}'>#{fileName}</li>")
      listElement.addClass("list-item")

      if index is 0
        listElement.addClass("matching-files-selected")

      @list.append(listElement)

    if filesToAdd.length is 1
      # do not add a click handler
      return

    @list.on 'click', (e) =>
      if not e.target? or e.target.nodeName is not "LI"
        return

      $('li.matching-files-selected').removeClass('matching-files-selected')
      e.target.className = "matching-files-selected"

      @emitter.emit 'select-file', filesToAdd[e.target.id]

  isModified: ->
    if @textEditor? and @originalTextEditor?
      return @textEditor.getText() !=
        @originalTextEditor.getTextInBufferRange(@editRange)

  saveChanges: ->
    if @textEditor? and @originalTextEditor?
      newText = @textEditor.getText()

      @originalTextEditor.setTextInBufferRange(@editRange, newText)
      @originalTextEditor.save()
