# Show the README text file
puts "\n\n"
puts IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
puts "\n"