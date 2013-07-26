make_slot = ->
  latest = null
  (setter) ->
    latest = setter
    ->
      if setter is latest
        latest.apply this, arguments


module.exports = make_slot
