{$, View} = require 'atom-space-pen-views'

module.exports =
class FileListView extends View
  @content: ->
    @div =>
      @ol class: 'list-group', outlet: 'list'

  initialize: ->
    @items = []

  destroy: ->
