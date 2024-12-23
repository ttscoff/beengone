desc "Development version check"
task :ver do
  v = IO.read("VERSION").strip

  puts "Version: #{v}"
end

desc "Dev version, bare with no newline"
task :cver do
  v = IO.read("VERSION").strip
  print v
end
