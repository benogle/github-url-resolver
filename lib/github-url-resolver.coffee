{CompositeDisposable} = require 'atom'
URLResolver = require './url-resolver'

module.exports = GithubURLResolver =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-text-editor', 'github-url-resolver:resolve-urls': => @resolveURLs()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  resolveURLs: ->
    editor = atom.workspace.getActiveTextEditor()
    selectedText = editor.getSelectedText()
    newTextPromise = URLResolver.resolveURLsInString(selectedText)
    newTextPromise.then (newText) ->
      editor.insertText(newText)
