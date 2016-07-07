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

    @addTooltips()

    @text = null
    @editRange = null
    @originalTextEditor = null

    @textEditor = null

    @emitter = new Emitter

    @onClickIcons()

  # Tear down any state and detach
  destroy: ->
    @subscriptions.dispose()

  addTooltips: ->
    # find the save and close keymap in case the user changed it
    saveAndCloseKeymap = atom.keymaps.findKeyBindings({
      command: 'code-peek:toggleCodePeekOff'
    })

    coreCancelKeymap = atom.keymaps.findKeyBindings({
      command: 'core:cancel'
    })

    # add all tooltips
    @subscriptions.add atom.tooltips.add @checkIcon,
      title: "Save and close (#{saveAndCloseKeymap[0].keystrokes})"

    @subscriptions.add atom.tooltips.add @codeIcon,
      title: "See entire file"

    @subscriptions.add atom.tooltips.add @closeIcon,
      title: "Close without saving (#{coreCancelKeymap[0].keystrokes})"

  onClickIcons: ->
    # emit true so that it saves the changes
    @checkIcon.on 'click', =>
      @emitter.emit 'check-icon-clicked', true

    # emit the file path and range so it can be opened in a new window
    @codeIcon.on 'click', =>
      fileInfo =
        filePath: @originalTextEditor.getPath()
        range: @editRange
      @emitter.emit 'code-icon-clicked', fileInfo

    # emit false so that it does not save the changes
    @closeIcon.on 'click', =>
      @emitter.emit 'close-icon-clicked', false

  onCheckIconClicked: (callback) ->
    @emitter.on 'check-icon-clicked', callback

  onCodeIconClicked: (callback) ->
    @emitter.on 'code-icon-clicked', callback

  onCloseIconClicked: (callback) ->
    @emitter.on 'close-icon-clicked', callback

  onSelectFile: (callback) ->
    @emitter.on 'select-file', callback

  setupForEditing: (functionInfo, originalTextEditor) ->
    if not functionInfo.text or not
      functionInfo.range or not
      originalTextEditor
        atom.notifications.addError("Could not setup for editing")
        return

    @text = functionInfo.text
    @editRange = functionInfo.range
    @originalTextEditor = originalTextEditor

    @descriptionLabel.html("Code Peek <span class='subtle-info-message'>\
      #{@originalTextEditor.getPath()}</span>")

    @textEditor = @textEditorView.getModel()
    @textEditor.setGrammar(@originalTextEditor.getGrammar())

  attachTextEditorView: (location) ->
    if not @text? or not @editRange? or not @originalTextEditor?
      throw new Error "Not all parameters set"

    @textEditor.setText(@text)
    @textEditor.setCursorBufferPosition([0, 0])
    @textEditor.scrollToCursorPosition()

    # fixes bug where text editor would scroll down on hitting spacebar
    @textEditorView.on 'keydown', (e) =>
      if e.keyCode == 32
        e.preventDefault()
        @textEditor.insertText(" ")

    switch location
      # handle if the height matters
      when "Bottom", "Top", "Header", "Footer", "Modal"
        maxHeight = atom.config.get("code-peek.maxHeight")
        $('.code-peek').removeAttr("style")
        $('.editor-container').css("max-height", maxHeight + "px")

      # handle if the width matters
      when "Left", "Right"
        maxWidth = atom.config.get("code-peek.maxWidth")
        $('.editor-container').removeAttr("style")
        $('.code-peek').css("max-width", maxWidth + "px")


  detachTextEditorView: =>
    # remove keybinding
    @textEditorView.off 'keydown'
    @textEditor = null

  addFiles: (filesToAdd) =>
    # wipe out all the old files
    $(@list).empty()

    # remove the click handler
    @list.off 'click'

    # add each file to the list element
    for file, index in filesToAdd
      fileName = file.filePath.replace(/^.*[\\\/]/, '')

      listElement = $("<li id='#{index}'>#{fileName}</li>")
      listElement.addClass("list-item")

      # default the first file as selected
      if index is 0
        listElement.addClass("matching-files-selected")

      @list.append(listElement)

    if filesToAdd.length is 1
      # do not add a click handler if only one file
      return

    # add click handler
    @list.on 'click', (e) =>
      if not e.target? or e.target.nodeName is not "LI"
        return

      # remove the old selected file and make the new file selected
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
