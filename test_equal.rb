class A
  attr_reader :a
  def initialize
    @a = 'a'
  end
  
  def ==(b)
    @a == b.a
  end
  
end

# Testing
if __FILE__ == $0
  m = A.new
  n = A.new
  puts m
  puts n
  arr = [m]
  puts m == n
end