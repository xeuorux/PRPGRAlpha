#===============================================================================
#
#===============================================================================
module PropertyMixin
  def get
      @getProc ? @getProc.call : nil
  end

  def set(value)
      @setProc.call(value) if @setProc
  end

  def description
      return @description ? @description : ""
  end
end

#===============================================================================
#
#===============================================================================
class EnumOption
  include PropertyMixin
  attr_reader :values
  attr_reader :name

  def initialize(name, description, options, getProc, setProc)
      @name    = name
      @values  = options
      @getProc = getProc
      @setProc = setProc
      @description = description
  end

  def next(current)
      index = current + 1
      index = @values.length - 1 if index > @values.length - 1
      return index
  end

  def prev(current)
      index = current - 1
      index = 0 if index < 0
      return index
  end
end

#===============================================================================
#
#===============================================================================
class EnumOption2
  include PropertyMixin
  attr_reader :values
  attr_reader :name

  def initialize(name, description, options, getProc, setProc)
      @name    = name
      @values  = options
      @getProc = getProc
      @setProc = setProc
      @description = description
  end

  def next(current)
      index = current + 1
      index = @values.length - 1 if index > @values.length - 1
      return index
  end

  def prev(current)
      index = current - 1
      index = 0 if index < 0
      return index
  end
end

#===============================================================================
#
#===============================================================================
class NumberOption
  include PropertyMixin
  attr_reader :name
  attr_reader :optstart
  attr_reader :optend

  def initialize(name, description, optstart, optend, getProc, setProc)
      @name     = name
      @optstart = optstart
      @optend   = optend
      @getProc  = getProc
      @setProc  = setProc
      @description = description
  end

  def next(current)
      index = current + @optstart
      index += 1
      index = @optstart if index > @optend
      return index - @optstart
  end

  def prev(current)
      index = current + @optstart
      index -= 1
      index = @optend if index < @optstart
      return index - @optstart
  end
end

#===============================================================================
#
#===============================================================================
class SliderOption
  include PropertyMixin
  attr_reader :name
  attr_reader :optstart
  attr_reader :optend


  def initialize(name, description, optstart, optend, optinterval, getProc, setProc)
      @name        = name
      @optstart    = optstart
      @optend      = optend
      @optinterval = optinterval
      @getProc     = getProc
      @setProc     = setProc
      @description = description
  end

  def next(current)
      index = current + @optstart
      index += @optinterval
      index = @optend if index > @optend
      return index - @optstart
  end

  def prev(current)
      index = current + @optstart
      index -= @optinterval
      index = @optstart if index < @optstart
      return index - @optstart
  end
end