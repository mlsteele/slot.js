plantTimeout = (ms, cb) -> setTimeout cb, ms

make_slot = (fetcher) ->
  ->
    fetcher.apply this, arguments

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

  describe 'orders well-behaved async fetchers', ->
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

    it 'works with one async fetcher', ->
      proxy_getter = -> raw_getter.apply this, arguments
      slot = make_slot proxy_getter
      target = 'not_yet_filled'
      callback = (data) -> target = data

      raw_getter = (callback) -> callback 'fetched_data_1'
      slot callback
      expect(target).toEqual 'fetched_data_1'

    it 'works with multiple ordered async fetchers', ->
      proxy_getter = -> raw_getter.apply this, arguments
      slot = make_slot proxy_getter
      target = 'not_yet_filled'
      callback = (data) -> target = data

      raw_getter = (callback) ->
        plantTimeout 100, -> callback 'fetched_data_1'
      slot callback
      raw_getter = (callback) ->
        plantTimeout 200, -> callback 'fetched_data_2'
      slot callback
      expect(target).toEqual 'not_yet_filled'
      jasmine.Clock.tick(120)
      expect(target).toEqual 'fetched_data_1'
      jasmine.Clock.tick(120)
      expect(target).toEqual 'fetched_data_2'

  describe 'handles out of order async fetchers', ->
    beforeEach -> jasmine.Clock.useMock()

    it 'works with multiple out of order async fetchers', ->
      proxy_getter = -> raw_getter.apply this, arguments
      slot = make_slot proxy_getter
      target = 'not_yet_filled'
      callback = (data) -> target = data

      raw_getter = (callback) ->
        plantTimeout 200, -> callback 'fetched_data_1'
      slot callback
      raw_getter = (callback) ->
        plantTimeout 100, -> callback 'fetched_data_2'
      slot callback

      expect(target).toEqual 'not_yet_filled'
      jasmine.Clock.tick(120)
      expect(target).toEqual 'fetched_data_2'
      jasmine.Clock.tick(120)
      expect(target).toEqual 'fetched_data_2'
