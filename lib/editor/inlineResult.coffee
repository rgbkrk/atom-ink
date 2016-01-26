# TODO: better scrolling behaviour
{CompositeDisposable} = require 'atom'
Result = require './Result'

module.exports =
class inlineResult extends Result
  constructor: (@editor, range, opts={}) ->
    super
    @type = 'inline'

  createView: ({error, content, fade}) ->
    @view = document.createElement 'div'
    @view.classList.add 'ink', 'inline', 'result'
    if error then @view.classList.add 'error'
    @view.style.position = 'absolute'
    @view.style.top = -@editor.getLineHeightInPixels() + 'px'
    @view.style.left = '10px'
    # @view.style.pointerEvents = 'auto'
    @view.addEventListener 'mousewheel', (e) ->
      e.stopPropagation()
    # clicking on it will bring the current result to the top of the stack
    @view.addEventListener 'click', =>
      @view.parentNode.parentNode.appendChild @view.parentNode

    @disposables.add atom.commands.add @view,
      'inline-results:clear': (e) => @remove()
    fade and @fadeIn()
    if content? then @view.appendChild content

  initMarker: ([start, end]) ->
    @marker = @editor.markBufferRange @lineRange(start, end),
      persistent: false
    @marker.result = @
    @editor.decorateMarker @marker,
      type: 'overlay'
      item: @view
    @disposables.add @marker.onDidChange (e) => @checkMarker e
