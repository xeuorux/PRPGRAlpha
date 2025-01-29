#===============================================================================
# Main options list
#===============================================================================
class Window_PokemonOption < Window_DrawableCommand
  attr_reader :mustUpdateOptions

  def initialize(options, x, y, width, height)
      @options = options
      @nameBaseColor   = Color.new(24 * 8, 15 * 8, 0)
      @nameShadowColor = Color.new(31 * 8, 22 * 8, 10 * 8)
      @selBaseColor    = Color.new(31 * 8, 6 * 8, 3 * 8)
      @selShadowColor  = Color.new(31 * 8, 17 * 8, 16 * 8)
      @optvalues = []
      @mustUpdateOptions = false
      for i in 0...@options.length
          @optvalues[i] = 0
      end
      super(x, y, width, height)
  end

  def [](i)
      return @optvalues[i]
  end

  def []=(i, value)
      @optvalues[i] = value
      refresh
  end

  def setValueNoRefresh(i, value)
      @optvalues[i] = value
  end

  def itemCount
      return @options.length + 1
  end

  def drawItem(index, _count, rect)
      rect = drawCursor(index, rect)
      optionname = (index == @options.length) ? _INTL("Exit") : @options[index].name
      optionwidth = rect.width * 9 / 20
      pbDrawShadowText(contents, rect.x, rect.y, optionwidth, rect.height, optionname,
         @nameBaseColor, @nameShadowColor)
      return if index == @options.length
      if @options[index].is_a?(EnumOption)
          if @options[index].values.length > 1
              totalwidth = 0
              for value in @options[index].values
                  totalwidth += contents.text_size(value).width
              end
              spacing = (optionwidth - totalwidth) / (@options[index].values.length - 1)
              spacing = 0 if spacing < 0
              xpos = optionwidth + rect.x
              ivalue = 0
              for value in @options[index].values
                  pbDrawShadowText(contents, xpos, rect.y, optionwidth, rect.height, value,
                     (ivalue == self[index]) ? @selBaseColor : baseColor,
                     (ivalue == self[index]) ? @selShadowColor : shadowColor
                  )
                  xpos += contents.text_size(value).width
                  xpos += spacing
                  ivalue += 1
              end
          else
              pbDrawShadowText(contents, rect.x + optionwidth, rect.y, optionwidth, rect.height,
                 optionname, baseColor, shadowColor)
          end
      elsif @options[index].is_a?(NumberOption)
          value = _INTL("Type {1}/{2}", @options[index].optstart + self[index],
             @options[index].optend - @options[index].optstart + 1)
          xpos = optionwidth + rect.x
          pbDrawShadowText(contents, xpos, rect.y, optionwidth, rect.height, value,
             @selBaseColor, @selShadowColor)
      elsif @options[index].is_a?(SliderOption)
          value = format(" %d", @options[index].optend)
          sliderlength = optionwidth - contents.text_size(value).width
          xpos = optionwidth + rect.x
          contents.fill_rect(xpos, rect.y - 2 + rect.height / 2,
             optionwidth - contents.text_size(value).width, 4, baseColor)
          contents.fill_rect(
              xpos + (sliderlength - 8) * (@options[index].optstart + self[index]) / @options[index].optend,
             rect.y - 8 + rect.height / 2,
             8, 16, @selBaseColor)
          value = format("%d", @options[index].optstart + self[index])
          xpos += optionwidth - contents.text_size(value).width
          pbDrawShadowText(contents, xpos, rect.y, optionwidth, rect.height, value,
             @selBaseColor, @selShadowColor)
      else
          value = @options[index].values[self[index]]
          xpos = optionwidth + rect.x
          pbDrawShadowText(contents, xpos, rect.y, optionwidth, rect.height, value,
             @selBaseColor, @selShadowColor)
      end
  end

  def update
      oldindex = index
      @mustUpdateOptions = false
      super
      dorefresh = (index != oldindex)
      if active && index < @options.length
          if Input.repeat?(Input::LEFT)
              self[index] = @options[index].prev(self[index])
              dorefresh = true
              @mustUpdateOptions = true
          elsif Input.repeat?(Input::RIGHT)
              self[index] = @options[index].next(self[index])
              dorefresh = true
              @mustUpdateOptions = true
          end
      end
      refresh if dorefresh
  end
end