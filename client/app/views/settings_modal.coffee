BaseView = require 'lib/base_view'
ImportView = require './import_view'
ComboBox = require './widgets/combobox'

module.exports = class SettingsModals extends BaseView

    id: 'settings-modal'
    className: 'modal fade'
    attributes: 'data-keyboard': false

    template: require('./templates/settings_modal')

    events:
        'click a#export': 'exportCalendar'
        'click #show-password': 'showPassword'
        'click #hide-password': 'hidePassword'

    getRenderData: ->
        account: @model

    initialize: ->
        @model = window.webDavAccount
        if @model?
            @model.placeholder = @getPlaceholder @model.token

    afterRender: ->

        @calendar = new ComboBox
            el: @$('#export-calendar')
            source: app.calendars.toAutoCompleteSource()

        @$('#importviewplaceholder').append new ImportView().render().$el

        # Show the modal.
        @$el.modal 'show'

        # Manage global interactions to close it.
        $(document).on 'keydown', @hideOnEscape

        @$el.on 'hidden', =>
            $(document).off('keydown', @hideOnEscape)

            # Redirects to home page.
            options = trigger: false, replace: true
            window.app.router.navigate '', options

            # The actual remove is done when modal is hidden, because it is
            # bound to behaviours managed by Bootsrap.
            @remove()

    # Close the modal when key `ESCAPE` is pressed.
    hideOnEscape: (e) ->
        # escape from outside a datetimepicker
        @close() if e.which is 27 and not e.isDefaultPrevented()


    # Close the modal.
    close: -> @$el.modal 'close'


    exportCalendar: ->
        calendarId = @calendar.value()
        if calendarId in app.calendars.toArray()
            window.location = "export/#{calendarId}.ics"

        else
            alert t 'please select existing calendar'


    # creates a placeholder for the password
    getPlaceholder: (password) ->
        placeholder = []
        placeholder.push '*' for i in [1..password.length] by 1
        return placeholder.join ''

    showPassword: ->
        @$('#placeholder').html @model.token
        @$('#show-password').hide()
        @$('#hide-password').show()

    hidePassword: ->
        @$('#placeholder').html @model.placeholder
        @$('#hide-password').hide()
        @$('#show-password').show()
