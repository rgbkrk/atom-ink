# TODO: better scrolling behaviour
{CompositeDisposable} = require 'atom'

module.exports =
  forLines: (ed, start, end, type = 'any') ->
    ed.findMarkers().filter((m)->m.result? &&
                                 m.getBufferRange().intersectsRowRange(start, end) &&
                                 (m.result.type == type || type == 'any'))
                    .map((m)->m.result)

  removeLines: (ed, start, end, type = 'any') ->
    rs = @forLines(ed, start, end, type)
    rs.map (r) -> r.remove()
    rs.length > 0

  removeAll: (ed = atom.workspace.getActiveTextEditor()) ->
    ed?.findMarkers().filter((m)->m.result?).map((m)->m.result.remove())

  removeCurrent: (e) ->
    if (ed = atom.workspace.getActiveTextEditor())
      for sel in ed.getSelections()
        if @removeLines(ed, sel.getHeadBufferPosition().row, sel.getTailBufferPosition().row)
          done = true
    e.abortKeyBinding() unless done

  # Commands

  activate: ->
    @subs = new CompositeDisposable
    @subs.add atom.commands.add 'atom-text-editor:not([mini])',
      'inline-results:clear-current': (e) => @removeCurrent e
      'inline-results:clear-all': => @removeAll()
      'inline-results:toggle': => @toggleCurrent()

  deactivate: ->
    @subs.dispose()
