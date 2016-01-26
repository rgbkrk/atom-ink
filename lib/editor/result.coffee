{CompositeDisposable} = require 'atom'

module.exports =
class Result
  constructor: (@editor, range, opts={}) ->
    @disposables = new CompositeDisposable
    @createView opts
    @initMarker range
    @text = @getText()
    @disposables.add @editor.onDidChange (e) => @validateText e

  fadeIn: ->
    @view.classList.add 'ink-hide'
    @timeout 20, =>
      @view.classList.remove 'ink-hide'

  lineRange: (start, end) ->
    [[start, 0], [end, @editor.lineTextForBufferRow(end).length]]

  remove: ->
    @view.classList.add 'ink-hide'
    @timeout 200, => @destroy()

  destroy: ->
    @marker.destroy()
    @disposables.dispose()

  invalidate: ->
    @view.classList.add 'invalid'
    @invalid = true

  validate: ->
    @view.classList.remove 'invalid'
    @invalid = false

  checkMarker: (e) ->
    if !e.isValid or @marker.getBufferRange().isEmpty()
      @remove()
    else if e.textChanged
      old = e.oldHeadScreenPosition
      nu = e.newHeadScreenPosition
      if old.isLessThan nu
        text = @editor.getTextInRange([old, nu])
        if text.match /^\r?\n\s*$/
          @marker.setHeadBufferPosition old

  validateText: ->
    text = @getText()
    if @text == text and @invalid then @validate()
    else if @text != text and !@invalid then @invalidate()

  # Utilities

  timeout: (t, f) -> setTimeout f, t

  getText: ->
    @editor.getTextInRange(@marker.getBufferRange()).trim()
