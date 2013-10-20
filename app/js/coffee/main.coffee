class CSSParser

    index: {}

    constructor: ->
        @ss = document.styleSheets[1]
        @buildIndex()

    buildIndex: ->
        i = 0
        _.each @ss.rules, (rule) =>
            # get the full statement (e.g. '.str { color: xxx; }')
            raw = rule.cssText.split('{')
            selector = raw[0].trim().substr(1)
            if @isValidRule(selector)
                # extract the color declaration
                color = raw[1].split('color:')[1]
                color = color.substr(0, color.indexOf(';')).trim()
                # store it so we can lookup/change its value
                @index[selector] = {
                    color: color
                    index: i
                }
            i++

    isValidRule: (selector) ->
        selector.length == 3

    modifyColor: (selector, newColor) ->
        if (@index[selector]?)
            @index[selector].color = newColor
            @ss.rules[@index[selector].index].style.color = newColor

    validateColor: (c) ->
        if (c.charAt(0) is '#')
            if (c.length != 4 and c.length != 7) then return false
        return true




class Main

    constructor: ->
        @css = new CSSParser( document.styleSheets[1] )
        @populateForm()

    updateColor: (hex = 'random') =>
        if hex is 'random' then hex = @getRandomHex()
        document.styleSheets[0].rules[50].style.color = hex

    getRandomHex: ->
        '#'+Math.floor(Math.random()*16777215).toString(16)

    populateForm: ->
        _.each @css.index, (obj, selector) =>
            el = @getFormInput(selector)
            if el.length > 0
                el.val( obj.color )
                el.keyup () => @respondToFormChange(el, obj, selector)

    respondToFormChange: (el, obj, selector) ->
        val = el.val()
        if @css.validateColor(val)
            el.removeClass('error')
            @css.modifyColor( selector, el.val() )
        else el.addClass('error')

    getFormInput: (selector) -> $("\##{selector}-input")



main = {}
$ ->
    prettyPrint() if prettyPrint?
    window.main = new Main()