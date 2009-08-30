#!/usr/bin/env ruby -wKU
$stdout.sync = true
IO.popen('rstakeout "rake test" lib/fleximage/* lib/fleximage/**/* test/unit/*') do |f|
  puts f.gets until f.eof?
end