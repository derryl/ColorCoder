Util =
    #validHex = /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/
    toHex: (c) ->
        hex = c.toString(16)
        if (hex.length == 1) 
            return '0' + hex
        else return hex

    convertRGBtoHex: (str) ->
        vals = Util.parseRGBString(str)
        if (vals.length != 3) then return false
        r = Util.toHex(vals[0])
        g = Util.toHex(vals[1])
        b = Util.toHex(vals[2])
        return ('#' + r + g + b)

    # Returns the three color values from a valid RGB string
    parseRGBString: (str) ->
        matchColors = /rgb\((\d{1,3}), (\d{1,3}), (\d{1,3})\)/
        matches = matchColors.exec str
        return [
            parseInt(matches[1])
            parseInt(matches[2])
            parseInt(matches[3])
        ]

    # accepted formats: #xxx, #xxxxxx, and rgb(x,x,x)
    validateColor: (str) ->
        /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/g.test(str)
        # if (c.charAt(0) is '#')
        #     if (c.length != 4 and c.length != 7) # incorrect length
        #         return false

        #     else return true
        # return false

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

    #updateColor: (hex = 'random') =>
    #    if hex is 'random' then hex = @getRandomHex()
    #    document.styleSheets[0].rules[50].style.color = hex

    getRandomHex: ->
        '#'+Math.floor(Math.random()*16777215).toString(16)

    populateForm: ->
        _.each @css.index, (obj, selector) =>
            el = @getFormInput(selector)
            if el.length > 0
                el.val( Util.convertRGBtoHex obj.color )
                el.keyup () => @respondToFormChange(el, obj, selector)

    respondToFormChange: (el, obj, selector) ->
        val = el.val()
        if Util.validateColor(val) is true
            el.removeClass('error')
            @css.modifyColor( selector, el.val() )
            console.log "setting .#{selector}"
        else 
            el.addClass('error')

    getFormInput: (selector) -> $("\##{selector}-input")



main = {}
$ ->
    prettyPrint() if prettyPrint?
    window.main = new Main()