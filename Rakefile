require "bundler/gem_tasks"
require 'rdoc/task'
require 'rake/testtask'

task :default => [:test]

RDoc::Task.new("doc") { |rdoc|
  rdoc.title = "Former - convert HTML to input forms for editable values"
  rdoc.rdoc_dir = 'docs'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
}

desc "Run all unit tests"
Rake::TestTask.new("test") { |t|
  t.libs << "lib"
  t.test_files = FileList['test/*.rb']
  t.verbose = true
}