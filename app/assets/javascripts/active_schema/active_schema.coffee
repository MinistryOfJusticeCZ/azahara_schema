$ = jQuery

class Filter
  constructor: (@name, @operatorEl, @valueEl)->
    that = this
    @hiddenEl = $('<input>', {name: @valueEl.attr('name'), type: 'hidden'}).insertAfter(@valueEl)
    chngFnc = (evt)->
      that.hiddenEl.val(that.shortValue())

    @operatorEl.change(chngFnc)
    @valueEl.change(chngFnc)
    chngFnc()

  shortValue: ()->
    if @valueEl.val() != ''
      @operatorEl.val() + '|' + @valueEl.val()
    else
      ''


$.widget 'active_schema.filters',
  options:
    nil: null
  _create: ()->
    that = this
    @filters = []
    @element.find('.row').each ()->
      that.filters.push new Filter($(this).data('name'), $(this).find('.operator-field'), $(this).find('.value-field'))

    @form = @element.closest('form')
