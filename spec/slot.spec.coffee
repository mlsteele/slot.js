plantTimeout = (ms, cb) -> setTimeout cb, ms

make_slot = ->
  # next = ->
  (setter) ->
    ->
      setter.apply this, arguments

describe 'A slot', ->
  describe 'is transparent for synchronous fetchers', ->
    it 'proxies an argument', ->
      target = 'not_yet_filled'
      setter = (data) -> target = data
      slot = make_slot()

      do slot -> setter 'fetched_data_1'
      expect(target).toEqual 'fetched_data_1'

    it 'proxies two arguments', ->
      target = 'not_yet_filled'
      setter = (nondata, data) -> target = data
      slot = make_slot()

      do slot -> setter 'fetched_data_not', 'fetched_data_1'
      expect(target).toEqual 'fetched_data_1'

    it 'proxies context', ->
      target = 'not_yet_filled'
      setter = (nondata) -> target = this.data
      slot = make_slot()

      do slot -> setter.apply {data: 'fetched_data_1'}
      expect(target).toEqual 'fetched_data_1'

  describe 'orders well-behaved async fetchers', ->
    beforeEach -> jasmine.Clock.useMock()

    it 'works with multiple ordered async fetchers', ->
      target = 'not_yet_filled'
      setter = (data) -> target = data
      slot = make_slot()

      plantTimeout 100, slot -> setter 'fetched_data_1'
      plantTimeout 200, slot -> setter 'fetched_data_2'

      expect(target).toEqual 'not_yet_filled'
      jasmine.Clock.tick(120)
      expect(target).toEqual 'fetched_data_1'
      jasmine.Clock.tick(120)
      expect(target).toEqual 'fetched_data_2'

  describe 'handles out of order async fetchers', ->
    beforeEach -> jasmine.Clock.useMock()

    it 'works with multiple out of order async fetchers', ->
      target = 'not_yet_filled'
      setter = (data) -> target = data
      slot = make_slot setter

      plantTimeout 200, slot -> setter 'fetched_data_1'
      plantTimeout 100, slot -> setter 'fetched_data_2'

      expect(target).toEqual 'not_yet_filled'
      jasmine.Clock.tick(120)
      expect(target).toEqual 'fetched_data_2'
      jasmine.Clock.tick(120)
      expect(target).toEqual 'fetched_data_2'
