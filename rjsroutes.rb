class Test

  def test(&block)
    puts 'yeee!'
  end

end  

t = Test.new
t.test do |map|
  puts "rwawr"
end


#class Array
#  def iterate!
#    self.each_with_index do |n, i|
#      self[i] = yield(n)
#    end
#  end
#end
# 
#array = [1, 2, 3, 4]
# 
#array.iterate! do |n|
#  n ** 2
#end
# 
#puts array.inspect