require('better-require')()
Tracker = require('./src/lib/reversion.coffee').Tracker

testNumber = 1

test = (start, callback, comparison) ->
  tracker = new Tracker(start)

  value = callback(tracker)

  console.log('###############')

  if value = comparison
    console.log('test ', testNumber, ' passed!')
  else
    console.log('test ', testNumber, ' failed!')
    console.log('expected ', comparison, ' but got ', value)

makeRange = (r1, c1, r2, c2) ->
  range = {
    start:
      row: r1
      column: c1
    end:
      row: r2
      column: c2
  }

  return range

# 1
test(
  'asdf'
  (tracker) ->
    tracker.mergeState(
      0
      {
        action: 'insertText'
        range: makeRange(4,0,0,0)
        text: 'abc'
      }
    )
  'asdfabc'
)
# 2

# 3
