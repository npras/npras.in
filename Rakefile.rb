require 'erb'
require 'date'

def template(name)
  ERB.new(File.read("templates/#{name}.erb"), trim_mode: '<>').result
end

def write_if_changed(filepath, new_content)
	if File.exist?(filepath)
		old_contents = File.read(filepath).strip
		if new_content.strip == old_content
      puts "no change: #{filepath}"
      return
    end
	end
	File.open(filepath, 'w') { |f| f.puts new_content }
end

@_self = 'Prasanna Natarajan'
@page_title = defined?(@title) ? "#{@title} | #{@_self}" : "#{@_self}"

puts template('head.html')

desc "build site/ from content/ and templates/"
task :make do

  # WRITE HOME PAGE
  html = template('head.html')
  html << template('home.html')
  html << template('foot.html')
	write_if_changed('site/home', html)
end

task :cleanup do
  sh "rm -rf site/*"
end

task :default => [:make]
