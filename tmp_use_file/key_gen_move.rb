#!/home/sun/.rvm/rubies/ruby-1.9.3-p448/bin/ruby

25.times do |i|
 `ssh-keygen -f \"/home/sun/.ssh/known_hosts\" -R 10.10.102.#{152+i}`
end
