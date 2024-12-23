desc 'Development version check'
task :ver do
  gver = `git ver`
  cver = IO.read('CHANGELOG.md').match(/^#+ (?:.*?) (\d+\.\d+\.\d+(\w+)?)/m)[1]
  res = `grep BEENGONE_VERSION beengone/main.m`
  version = res.match(/(?mi)(?<=#define BEENGONE_VERSION ")(\d+\.\d+\.\d+(\..+)?)(?=")/)[1]

  puts "git tag: #{gver}"
  puts "version.rb: #{version}"
  puts "changelog: #{cver}"
end

desc 'Changelog version check'
task :cver do
  puts IO.read(File.join(File.dirname(__FILE__), 'CHANGELOG.md')).match(/^#+ (?:.*?) (\d+\.\d+\.\d+(\w+)?)/)[1]
end

# merge
def semantic(major, minor, inc, pre, type = 'inc')
  case type
  when /^maj/
    major += 1
    minor = 0
    inc = 0
  when /^min/
    minor += 1
    inc = 0
  when /^(pre|pat)/
    pre.next!
  else
    inc += 1
  end
  [major, minor, inc, pre]
end
# /merge

# merge
desc 'Bump incremental version number'
task :bump, :type do |_, args|
  args.with_defaults(type: 'inc')
  version_file = 'beengone/main.m'
  content = IO.read(version_file)
  content.sub!(/(?mi)(?<=#define BEENGONE_VERSION ")(?<major>\d+)\.(?<minor>\d+)\.(?<inc>\d+)(?<pre>\S+)?(?=")/) do
    m = Regexp.last_match

    major, minor, inc, pre = semantic(m[:major].to_i, m[:minor].to_i, m[:inc].to_i, m[:pre], args[:type])

    $stdout.puts "At version #{major}.#{minor}.#{inc}#{pre}"
    %(#{major}.#{minor}.#{inc}#{pre})
  end
  File.open(version_file, 'w+') { |f| f.puts content }
end
# /merge
