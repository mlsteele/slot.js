# make_slot() creates a slot for managing callbacks.
# The slot will only allow the last registered callback to fire.
make_slot = ->
  latest = null
  # callback is the 'setter' or 'renderer' function
  # to be locked into the slot.
  slot = (callback) ->
    latest = callback
    ->
      if callback is latest
        latest.apply this, arguments

  # clear the slot by registering a blank function
  slot.clear = -> slot ->

  return slot


module.exports = make_slot
