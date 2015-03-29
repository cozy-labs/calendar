BaseView = require '../lib/base_view'
colorhash = require 'lib/colorhash'

module.exports = class MenuItemView extends BaseView

    tagName: 'li'
    className: 'tagmenuitem'
    template: require './templates/menu_item'

    events:
        'click > span': 'toggleVisible'
        'click .calendar-remove': 'onRemoveCalendar'
        'click .calendar-rename': 'onRenameCalendar'
        'click .calendar-export': 'onExportCalendar'

        'click .dropdown-toggle': 'hideColorPicker'
        'click .calendar-color': 'showColorPicker'
        'change .color-picker': 'setColor'
        'blur input.calendar-name': 'onRenameValidation'
        'keyup input.calendar-name': 'onRenameValidation'

    getRenderData: ->
        label: @model.get 'name'

    afterRender: ->
        @buildBadge @model.get 'color'

    toggleVisible: ->
        unless app.router.onCalendar
            app.router.navigate 'calendar', true
        @startSpinner()
        # make asynchronous to allow the spinner to show up, before make.set
        # and it's heavy load events chain block the UI for à while.
        setTimeout =>
                @model.set 'visible', not @model.get 'visible'
                @stopSpinner()
                @render()
            , 1

    showColorPicker: (ev) ->
        ev?.stopPropagation() # avoid dropdown auto close.

        @$('.color-picker').show()
        @$('.calendar-color').hide()

        # TinyColorPicker seems buggy, refresh it on each open.
        @colorPicker = @$('.color-picker')
        @colorPicker.tinycolorpicker()
        @$('.track').attr 'style', 'display: block;'

    hideColorPicker: =>
        @$('.color-picker').hide()
        @$('.calendar-color').show()

    setColor: (ev)  ->
        color = @colorPicker.data()?.plugin_tinycolorpicker?.colorHex
        @model.set 'color', color
        @buildBadge color
        @model.save()

        @$('.dropdown-toggle').dropdown 'toggle'
        @hideColorPicker()

        # Gone after succefull color pick, put it back.
        @$('.dropdown-toggle').on 'click', @hideColorPicker


    # Handle `blur` and `keyup` (`enter` and `esc` keys) events in order to
    # rename a calendar.
    onRenameValidation: (event) ->

        input = $ event.target
        calendarName = @model.get 'name'

        key = event.keyCode or event.charCode
         # `escape` key cancels the edition.
        if key is 27
            input.remove()
            # re-appends text element
            @rawTextElement.insertAfter @$('.badge')

            # Restores the badge color
            @buildBadge calendarName

            # Shows the menu again
            @$('.dropdown-toggle').show()

        # `blur` event and `enter` key trigger the persistence
        else if (key is 13 or event.type is 'focusout')
            @startSpinner()
            app.calendars.rename calendarName, input.val(), =>
                @stopSpinner()
        else
            @buildBadge colorhash input.val()


    # Replace the calendar's name by an input to edit the name.
    onRenameCalendar: ->
        calendarName = @model.get 'name'

        # Create the input and replace the raw text by it.
        template = """
        <input type="text" class="calendar-name" value="#{calendarName}"/>
        """
        input = $ template

        # Keep a reference to the text element so we can re-append it later.
        @rawTextElement = @$('.calendar-name').detach()
        input.insertAfter @$('.badge')

        # Hides the menu during edition.
        @$('.dropdown-toggle').hide()

        # Focus the input and select its value/
        input.focus()
        input[0].setSelectionRange 0, calendarName.length


    onRemoveCalendar: ->
        calendarName = @model.get 'name'
        message = t 'confirm delete calendar', {calendarName}
        if confirm(message)
            @startSpinner()
            app.calendars.remove calendarName, =>
                @stopSpinner()

    onExportCalendar: ->
        calendarName = @model.get 'name'
        window.location = "export/#{calendarName}.ics"

    buildBadge: (color) ->
        visible = @model.get 'visible'
        backColor = if visible then color else "transparent"
        borderColor = if visible then "transparent" else color

        styles =
            'background-color': backColor
            'border': "1px solid #{borderColor}"
        @$('.badge').css styles

    startSpinner: ->
        @$('.spinHolder').show()

    stopSpinner: ->
        @$('.spinHolder').hide()
