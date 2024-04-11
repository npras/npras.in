require 'erb'
require 'date'
require 'debug'
require 'rake/clean'

# vars, constants, configs

# Rake.application.options.trace_rules = true

SITE_NAME = 'Prasanna Natarajan'
TITLE = "%{page_title} | #{SITE_NAME}"

INPUT_BASEDIR = '_input'
OUTPUT_BASEDIR = '_output'
TEMPLATE_DIR = 'templates'
HOME_PAGE = File.join OUTPUT_BASEDIR, 'index.html'
INPUT_FILES = Rake::FileList.new "#{INPUT_BASEDIR}/**/*.txt"
OUTPUT_FILES = INPUT_FILES.pathmap "%{^#{INPUT_BASEDIR}/,#{OUTPUT_BASEDIR}/}X.html"

####################

# Rake stuff

task :default => :build_site

deps = [
  OUTPUT_BASEDIR,
  *OUTPUT_FILES,
  HOME_PAGE,
]
desc 'build site'
task :build_site => deps

directory OUTPUT_BASEDIR

rule '.html' => ->(f){input_file_for(f)} do |t|
  mkdir_p t.name.pathmap('%d')
  do_work_son input_file: t.source, output_file: t.name
end

file HOME_PAGE do |t|
  html = build_html_from t('home')
  write_file t.name, html
end

CLEAN.include OUTPUT_FILES, OUTPUT_BASEDIR
# CLOBBER.include 'site.zip'

####################

# Ruby stuff

def input_file_for output_file
  output_file
    .pathmap("%{^#{OUTPUT_BASEDIR}/,#{INPUT_BASEDIR}/}p")
    .ext('.txt')
end

def do_work_son input_file:, output_file:
  lines = File.readlines input_file
  body = lines.join
  title = page_title_from input_file, lines.first.strip
  @page_title = TITLE % {page_title: title}
  write_file output_file, build_html_from(body)
end

def build_html_from body_content
  html = t('head')
  html << t('body')
  html << body_content
  html << t('foot')
  html
end

def t name
  content = File.read File.join(TEMPLATE_DIR, "#{name}.erb")
  ERB.new(content, trim_mode: '<>').result
end

def write_file(path, content) = File.open(path, 'w') { _1.puts content }

def page_title_from input_file, line
  match_data = /<!--\s+(.+)\s+-->/.match line
  match_data[1]
rescue
  fail "No title found for input_file: #{input_file}"
end
