{View} = require 'atom-space-pen-views'

module.exports =
class FileListView extends View
  @content: ->
    @ul class: 'file-list'

  initialize: ->

  destroy: ->

#
# module.exports =
# class FileListView extends SelectListView
#   initialize: ->
#     super
#     @addClass('from-right')
#     @setItems(['Hello', 'World'])
#     @panel ?= atom.workspace.addModalPanel(item: this)
#     @panel.show()
#     @focusFilterEditor()
#
#   viewForItem: (item) ->
#     "<li>#{item}</li>"
#
#   confirmed: (item) ->
#     console.log "#{item} was selected"
#
#   cancelled: ->
#     console.log "this view was cancelled"
