require 'erb'
require 'date'
require 'debug'

Rake.application.options.trace_rules = true

@_self = 'Veeran The Hero'
@page_title = defined?(@title) ? "#{@title} | #{@_self}" : "#{@_self}"

INPUT_FILES = Rake::FileList.new('_input/**/*.txt')
OUTPUT_FILES = INPUT_FILES.pathmap("%{^_input/,_output/}X.html")

####################

def template(name)
  ERB.new(File.read("layout/#{name}.erb"), trim_mode: '<>').result
end

def build_output_file_string(body_content)
  html = template('head.html')
  html << template('body.html')
  html << body_content
  html << template('foot.html')
  html
end

def write_to_file(filepath, content)
  File.open(filepath, 'w') { |f| f.puts content }
end

def input_file_for(output_file)
  output_file.pathmap('%{^_output/,_input/}p').ext('.txt')
end

def do_work_son(input_file, output_file)
  @url = File.basename(input_file)
  lines = File.readlines(input_file)
  /<!--\s+(.+)\s+-->/.match lines.shift
  @title = $1
  body = lines.join('')
  @page_title = "#{@title} | #{@_self}"
  write_to_file(output_file, build_output_file_string(body))
end

####################

task :clean do
  rm_rf '_output'
end

directory '_output'

rule '.html' => ->(f){input_file_for(f)} do |t|
  input_file = t.source
  output_file = t.name
  mkdir_p output_file.pathmap('%d')
  do_work_son(input_file, output_file)
end

####################

task :default => :build_site

task :build_site => [*OUTPUT_FILES, '_output']
