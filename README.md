Slot.js
=======

Slot.js can create slots.
A slot is responsible for firing only the latest registered callback.
A slot will not fire old callbacks.

Usage:

    slot = make_slot()

    # to fire immediately
    # for synchronous data
    do slot (data) -> render(data)

    # to register a callback
    # for asynchronous data
    # assume async_fetcher takes 2 arguments
    #    a `url` and a `callback`
    async_fetcher 'http://data.please/foobar', slot (data) ->
      render(data)

    # to clear the slot
    # so that no old callbacks fire
    slot ->

TODO:
- test with non-anonymous callback functions
- add slot.clear() method
- fix file structure, separate slot.js from test
