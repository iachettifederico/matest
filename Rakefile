require "bundler/gem_tasks"

task default: :matest
task :matest do
  arg_files = ENV["FILES"] && ENV["FILES"].split(/[\s,]+/)
  all_files = Rake::FileList["./spec/matest_specs/**/*_spec.rb"]
  files = arg_files || all_files
  puts "\nRuning tests for: #{ files.join(" ") }\n\n"

  system *["./bin/matest"].concat(files)
end
