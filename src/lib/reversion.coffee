Tracker = (initialState) ->
  this.state = initialState.split("\n")
  this.history = []
  this.version = -1

Tracker.prototype.getValue = ->
  return this.state.join("\n")

Tracker.prototype.currentVersion = ->
  return this.history[this.version]

Tracker.prototype.rollback = (n) ->
  for i in [1..n] by 1
    this.stepBackwards()

Tracker.prototype.apply = (n) ->
  for i in [1..n] by 1
    this.stepForwards()

Tracker.prototype.removeLines = (startRow, endRow) ->
  this.state = this.state.slice(0, startRow + 1) + this.state.slice(endRow + 1, this.state.length)
  
Tracker.prototype.removeText = (row, startCol, endCol) ->
  oldLine = this.state[row]
  newLine = oldLine.substring(0, startCol + 1)
  newLine += oldLine.substring(endCol + 1, oldLine.length)

  this.state[row] = newLine

Tracker.prototype.insertText = (row, col, text) ->
  oldLine = this.state[row]
  newLine = oldLine.substring(0, col + 1)
  newLine += text
  newLine += oldLine.substing(col + 1, oldLine.length)

  this.state[row] = newLine

Tracker.prototype.stepForwards = ->
  this.version++
  data = this.currentVersion()

  if data.action == 'removeLines'
    this.removeLines(data.range.start.row, data.range.end.row)
  else if data.action == 'removeText'
    row = data.range.start.row
    startCol = data.range.start.column
    endCol = data.range.end.column

    this.removeText(row, startCol, endCol)
  else # this.data == 'insertText' 
    row = data.range.start.row
    col = data.range.start.column

    this.insertText(row, col, data.text)

Tracker.prototype.stepBackwards = ->
  this.version--
  data = this.currentVersion()

  if data.action == 'removeLines'
    # does not take into account if multiple lines were deleted
    this.state.splice(data.range.start.row, 0, "")
  else if data.action == 'removeText'
    row = data.range.start.row
    col = data.range.start.column
    
    this.insertText(row, col, data.text)
  else
    row = data.range.start.row
    startCol = data.range.start.column
    endCol = data.range.end.column

    removeText(row, startCol, endCol)

Tracker.prototype.addState = (data) ->
  this.version++ if this.version == -1

  this.history.splice(
    this.version
    0
    {
      action: data.action
      range: data.range
      text: data.text
    }
  )
  this.stepForwards()

Tracker.prototype.mergeState = (sessionVersion, data) ->
  if this.version == sessionVersion
    this.addState(data)
  else
    versionDiff = this.version - sessionVersion
    this.rollback(versionDiff)
    this.addState(data)
    this.apply(versionDiff)

  return this.getValue()

exports.Tracker = Tracker
