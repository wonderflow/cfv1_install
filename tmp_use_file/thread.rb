#!/usr/bin/ruby
require 'thread'

class Install
  @@x = Hash.new

  def initialize(url)
    @url = url
    if @@x[url] == nil
      puts url
      @@x[url.to_sym] = Mutex.new
    end
  end

  def work()
    @@x[@url.to_sym].synchronize do
    puts @url+" start."
    5.times do 
      puts @url+" ."
      sleep 1
    end
    puts @url+" end."
    end
  end
end

thread = [] 
job = []

3.times do |i|
  job << Install.new(i.to_s)
end
2.times do |i|
  job << Install.new(i.to_s)
end



job.each do |x|
  thread << Thread.new do
    x.work
  end
end

thread.each do |s|
  s.join
end
