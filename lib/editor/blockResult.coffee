# TODO: better scrolling behaviour
{CompositeDisposable} = require 'atom'
Result = require './Result'

module.exports =
class blockResult extends Result
  constructor: (@editor, range, opts={}) ->
    super
    @type = 'block'

  createView: ({error, content, fade}) ->
    @view = document.createElement 'div'
    @view.classList.add 'ink', 'under', 'result'
    if error then @view.classList.add 'error'
    # @view.style.pointerEvents = 'auto'
    @view.addEventListener 'mousewheel', (e) ->
      e.stopPropagation()
    @disposables.add atom.commands.add @view,
      'inline-results:clear': (e) => @remove()
    fade and @fadeIn()
    if content? then @view.appendChild content

  initMarker: ([start, end]) ->
    @marker = @editor.markBufferRange @lineRange(start, end),
      persistent: false
    @marker.result = @
    @editor.decorateMarker @marker,
      type: 'block'
      item: @view
      position: 'after'
    @disposables.add @marker.onDidChange (e) => @checkMarker e
