{$, View} = require 'atom-space-pen-views'

module.exports =
class FileListView extends View
  @content: ->
    @div =>
      @ol class: 'list-group', outlet: 'list'

  initialize: ->
    @items = []

  destroy: ->

  addFile: (filePath, initialLine) =>
    #TODO only display the file name
    #TODO add click handler to change to new text editor... not sure how
    #TODO add styling
    @list.append("<li>#{filePath}</li>")

  removeAllFiles: =>
    $(@list).empty()
