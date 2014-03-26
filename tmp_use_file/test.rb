#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

class Test
  attr_accessor :num
  attr_accessor :job
  def initialize(num,job)
    @num = num
    @job = job
  end
end

a = []

a << Test.new(1,'jobA')
a << Test.new(2,'jobB')
a << Test.new(1,'jobC')
a << Test.new(3,'jobD')

b = Hash.new

a.delete_if do |i|
  puts i.num
  if b[i.num] == nil
    b[i.num] = true
    true
  else
    false
  end
end

a.each do |i|
  puts i.num,i.job
end
