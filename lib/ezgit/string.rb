class String

  def bold
    "\033[1m" + self + "\033[0m"
  end

  def black
    "\033[30m" + self + "\033[0m"
  end

  def red
    "\033[31m" + self + "\033[0m"
  end

  def green
    "\033[32m" + self + "\033[0m"
  end

  def yellow
    "\033[33m" + self + "\033[0m"
  end

  def blue
    "\033[34m" + self + "\033[0m"
  end

  def magenta
    "\033[35m" + self + "\033[0m"
  end

  def cyan
    "\033[36m" + self + "\033[0m"
  end

  def white
    "\033[37m" + self + "\033[0m"
  end

end