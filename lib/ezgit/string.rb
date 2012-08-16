CLEAR   = "\033[0m"
BOLD    = "\033[1m" 
BLACK   = "\033[30m"
GREEN   = "\033[32m"
RED     = "\033[31m"
YELLOW  = "\033[33m"
BLUE    = "\033[34m"
MAGENTA = "\033[35m"
CYAN    = "\033[36m"
WHITE   = "\033[37m"

class String

  def bold
    BOLD+ self + CLEAR
  end

  def black
    BLACK + self + CLEAR
  end

  def red
    RED + self + CLEAR
  end

  def green
    GREEN + self + CLEAR
  end

  def yellow
    YELLOW + self + CLEAR
  end

  def blue
    BLUE + self + CLEAR
  end

  def magenta
    MAGENTA + self + CLEAR
  end

  def cyan
    CYAN + self + CLEAR
  end

  def white
    WHITE + self + CLEAR
  end

end