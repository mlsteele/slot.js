plantTimeout = (ms, cb) -> setTimeout cb, ms

make_slot = (f) -> -> f.apply this, arguments

describe 'A slot', ->
  describe 'is transparent for synchronous fetchers', ->
    it 'passes through an argument', ->
      raw_getter = (callback) -> callback 'fetched_data_1'
      slot = make_slot raw_getter
      target = 'not_yet_filled'
      callback = (data) -> target = data

      slot callback
      expect(target).toEqual 'fetched_data_1'

    it 'passes through two arguments', ->
      raw_getter = (cb1, cb2) ->
        cb2 'fetched_data_override'
        cb1 'fetched_data_1'
      slot = make_slot raw_getter
      target = 'not_yet_filled'
      callback = (data) -> target = data

      slot (->), callback
      expect(target).toEqual 'fetched_data_override'

    it 'passes through context', ->
      raw_getter = (callback) -> callback.apply {'foo': 'bar'}
      slot = make_slot raw_getter
      target = 'not_yet_filled'
      callback = (no_data) -> target = this.foo

      slot callback
      expect(target).toEqual 'bar'

  describe 'orders well-behaved async callbacks', ->
    beforeEach -> jasmine.Clock.useMock()

    it 'unrelated async clock test', ->
      foo = 1

      spy = jasmine.createSpy 'timerCallback'

      plantTimeout 100, ->
        foo = 2
        spy()

      expect(foo).toBe 1
      expect(spy).not.toHaveBeenCalled()
      jasmine.Clock.tick(101);
      expect(foo).toBe 2
      expect(spy).toHaveBeenCalled()

    # it 'works with one async callback', ->
    #   raw_getter = (callback) -> plantTimeout 100, -> callback
    #   slot = make_slot raw_getter
    #   target = 'not_yet_filled'
    #   callback = (no_data) -> target = this.foo

    #   slot callback
    #   expect(target).toEqual 'bar'
