require 'erb'
require 'date'
require 'debug'

# vars, constants, configs

Rake.application.options.trace_rules = true

@_self = 'Veeran The Hero'
@page_title = defined? @title ? %Q(#{@title} | #{@_self}) : "#{@_self}"

INPUT_BASEDIR = '_input'
OUTPUT_BASEDIR = '_output'
INPUT_FILES = Rake::FileList.new "#{INPUT_BASEDIR}/**/*.txt"
OUTPUT_FILES = INPUT_FILES.pathmap "%{^#{INPUT_BASEDIR}/,#{OUTPUT_BASEDIR}/}X.html"

####################

# Rake stuff

task :default => :build_site

task :build_site => [*OUTPUT_FILES, OUTPUT_BASEDIR]

directory OUTPUT_BASEDIR

rule '.html' => ->(f){input_file_for(f)} do |t|
  input_file = t.source
  output_file = t.name
  mkdir_p output_file.pathmap('%d')
  do_work_son input_file, output_file
end

task :clean do
  rm_rf '_output'
end

####################

# Ruby stuff

def input_file_for output_file
  output_file
    .pathmap("%{^#{OUTPUT_BASEDIR}/,#{INPUT_BASEDIR}/}p")
    .ext('.txt')
end

def do_work_son input_file, output_file
  @url = File.basename input_file
  lines = File.readlines input_file
  /<!--\s+(.+)\s+-->/.match lines.shift
  @title = $1
  body = lines.join ''
  @page_title = %Q(#{@title} | #{@_self})
  write_to_file output_file, build_output_file_string(body)
end

def build_output_file_string body_content
  html = template('head.html')
  html << template('body.html')
  html << body_content
  html << template('foot.html')
  html
end

def template name
  content = File.read "layout/#{name}.erb"
  ERB.new(content, trim_mode: '<>').result
end

def write_to_file filepath, content
  File.open(filepath, 'w') { |f| f.puts content }
end
