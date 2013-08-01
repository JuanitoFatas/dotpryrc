module PryrcHelpers
  extend self

  ## Get your user information
  # http://linux.die.net/man/3/getpwuid
  def user
    Etc.getpwuid[:gecos].delete(",").strip || Rubyist
  end

  ## this is a randomly-chosen numerics
  def pryrc_speed
    0.008 * [*1..5].sample
  end

  ## Welcome messages inspired from Emacs SLIME
  def welcome_messages
    [
      "Let the hacking commence!",
      "Hacks and glory await!",
      "Hack and be merry!",
      "Your hacking starts... NOW!",
      "May the source be with you!",
      "Take this REPL, brother, and may it serve you well.",
      "Lemonodor-fame is but a hack away!",
      "#{user} this could be the start of a beautiful program.",
      "Scientifically-proven optimal words of hackerish encouragement.",
      "Happy Hacking!",
      "Oh wow. Oh wow. Oh wow. You're hacking with Pry now!"
    ].sample
  end

  def farewell_messages
    [
     "Nice hack with you!",
     "We'll hack soon!",
     "See you next hack!",
     "Glad you hack Ruby with Pry!",
     "We'll take a rainhack!",
     "That was a good hack.",
     "Gone with Ruby..."
    ].sample
  end

  ## Progress bar for .pryrc
  # done is false, "==>\r"
  # done is true , "==> Load Completed!\n"
  def pryrc_progress_bar(len=1, done=false)
    last = "\r"
    last = " Load Completed!\n" if done
    "|#{'====' * len}>#{last}"
  end

  ## 2/3 true, 1/3 false to increase farewell comes more often.
  def true_true_or_false
    [true, true, false].sample
  end

  ## Interpret time (in seconds) to human-readable hash.
  # These numbers are took by Google Search
  # Google: How many seconds in X
  # where X is year, month, day...etc.
  def interpret_time time
    year = 31_556_926
    month = 2_629_743.83
    day = 86400
    hour = 3600
    min = 60
    sec = 1
    res = { year: 0, month: 0, day: 0, hour: 0, minute: 0, second: 0 }
    units = res.keys # = [:year, :month, :day, :hour, :minute, :second]
    [year, month, day, hour, min, sec].each_with_index do |unit, index|
      ## Divide by unit, set the quotient and remainder accordingly.
      # if time = 1200 seconds,
      # time.divmod unit will evaluates to
      # 1201/31_556_926 = 0..1201
      # which yields { :year => 0 }.
      # repeat with time = 1200 seconds and next unit, which is month.
      res[units[index]], time = time.divmod unit
    end
    ## delete time unit with zero because won't need to print
    # 0 days 1 hour 30 minutes, just print 1 hour 30 minutes.
    # 0 second is left for a special case:
    # interpreted_time = 'ever' if interpreted_time == '0 second'
    time_to_s res.delete_if { |key, val| val.zero? if key != :second }
  end

  ## Add color to terminal text.
  # \033 is 100% POSIX compatible. Use \e is also fine.
  # http://www.termsys.demon.co.uk/vtansi.htm
  # Foreground Colours
  #   30  Black
  #   31  Red
  #   32  Green
  #   33  Yellow
  #   34  Blue
  #   35  Magenta
  #   36  Cyan
  #   37  White
  def colorize(text, color_code)
    "\033[#{color_code}m#{text}\033[0m"
  end

  private

  ## Covert human-readable time hash to string.
  # { year: 3, month: 4, day: 15 } will result in
  # => "3 years 4 months 15 days"
  def time_to_s time_hash
    suffix = ''
    result = ''
    time_hash.each_pair do |unit, value|
      suffix = 's' if value > 1
      result << "#{value} #{unit}#{suffix} "
    end
    result.strip! # Remove last whitespace in "3 years 4 months 15 days ".
  end

end # End of PryrcHelpers

# ==================
# Monkey Patches
# ==================

class Array

  ## Require many gems at once.
  # Input: array of gems' name
  # The side effect is requiring all of them.
  def ___require_gems
    missing = []
    self.each do |e|
      begin
        require e
      rescue LoadError => err
        missing << e
      end
    end
    if !missing.empty?
      puts 'Missing ' + missing.join(' ') + ' goodies :('
    end
  end

  ## Generate a toy of array to play with.
  # Array.toy => [1,2,3,4,5,6,7,8,9,10]
  # Array.toy { |i| i ** 2 }
  # => [0,1,4,9,16,25,36,49,64,81]
  def self.toy(n = 10, &block)
    block_given? ? Array.new(n, &block) : Array.new(n) { |i| i+1 }
  end

end

class Hash

  ### Generate a toy of hash to play with.
  # Hash.toy 3
  # => { 1 => "a", 2 => "b", 3 => "c" }
  def self.toy(n = 10)
    Hash[Array.toy(n).zip(Array.toy(n){ |c| (96+(c+1)).chr })]
  end

end

class Object

  ## Open file with exact location via editor of your choice.
  # Defaults to Sublime Text.
  def subl(method_name, editor='subl')
    file, line = method(method_name).source_location
    `"#{editor}" "#{file}:#{line}"`
  end

  ## Only return the methods not present on basic objects
  def interesting_methods
    (self.methods - Object.instance_methods).sort
  end

  ## Safely require gem with message when a LoadError is signaled.
  def safe_require(gem, msg)
    begin
      require gem
    rescue LoadError
      puts 'No ' + "#{gem}" ' available.'
      puts msg
    end
  end

end

# ==============================
#   Helpers!
# ==============================

## Pry.active_sessions
class Pry
  class << self
    attr_accessor :active_sessions
  end
end

## YAML#to_yaml abstraction.
# y("language: ruby\nrvm:\n  - 2.0.0\n  - 1.9.3\nscript: rake test\n")
# =>
# --- |
#   language: ruby
#   rvm:
#     - 2.0.0
#     - 1.9.3
#   script: rake test
def y(obj)
  puts obj.to_yaml
end

### Benchmark

## Benchmark.measure abstraction.
# puts bm { "a"*1_000_000_000 }
def bm(&block)
  Benchmark.measure &block
end

## Generate Lorem Ipsum String.
def lorem
  "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
end