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
  firstHalf = this.state.slice(0, startRow + 1)
  secondHalf = this.state.slice(endRow + 1, this.state.length)
  this.state = firstHalf.concat(secondHalf)
  
Tracker.prototype.removeText = (row, startCol, endCol) ->
  oldLine = this.state[row]
  newLine = oldLine.substring(0, startCol)
  newLine += oldLine.substring(endCol, oldLine.length)

  this.state[row] = newLine

Tracker.prototype.insertText = (row, col, text) ->
  if text == "\n"
    this.state.splice(row + 1, 0, "")
  else
    oldLine = this.state[row]
    newLine = oldLine.substring(0, col + 1)
    newLine += text
    newLine += oldLine.substring(col + 1, oldLine.length)

    this.state[row] = newLine

Tracker.prototype.executeStep = (data) ->
  if data.action == 'removeLines'
    this.removeLines(data.range.start.row, data.range.end.row)
  else if data.action == 'removeText'
    if data.text == "\n"
      this.removeLines(data.range.start.row, data.range.end.row)
    else
      row = data.range.start.row
      startCol = data.range.start.column
      endCol = data.range.end.column

      this.removeText(row, startCol, endCol)
  else # data.action == 'insertText' 
    row = data.range.start.row
    col = data.range.start.column

    this.insertText(row, col, data.text)

Tracker.prototype.undoStep = (data) ->
  if data.action == 'removeLines'
    this.state.splice(data.range.start.row, 0, "")
  else if data.action == 'removeText'
    row = data.range.start.row
    col = data.range.start.column

    this.insertText(row, col, data.text)
  else # data.action == 'insertText'
    row = data.range.start.row
    startCol = data.range.start.column
    endCol = data.range.end.column

    this.removeText(row, startCol + 1, endCol + 1)

Tracker.prototype.stepForwards = ->
  this.version++
  this.executeStep(this.currentVersion())

Tracker.prototype.stepBackwards = ->
  this.undoStep(this.currentVersion())
  this.version--

Tracker.prototype.spliceHistory = (data) ->
  this.history.splice(
    if this.version == -1 then 0 else this.version + 1
    0
    {
      action: data.action
      range: data.range
      text: data.text
    }
  )

Tracker.prototype.addState = (data) ->
  this.spliceHistory(data)

  this.stepForwards()

Tracker.prototype.mergeState = (sessionVersion, data) ->
  if this.version == sessionVersion
    this.addState(data)
  else
    versionDiff = this.version - sessionVersion
    this.rollback(versionDiff)

    this.executeStep(data)

    this.apply(versionDiff)
 
    this.spliceHistory(data)
    this.version++

  return this.getValue()

exports.Tracker = Tracker
