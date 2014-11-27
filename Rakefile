require "bundler/gem_tasks"
task :matest do
  files = Rake::FileList["./spec/matest_specs/**/*_spec.rb"]
  puts "\nRuning tests for: #{ files }\n\n"

  system *["./bin/mt"].concat(files)
end
