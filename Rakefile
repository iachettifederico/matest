require "bundler/gem_tasks"

task default: :matest

task :spec do
  arg_files = (ENV["FILES"] && ENV["FILES"].split(/[\s,]+/)) || [ENV["SPEC"]]
  if arg_files
    arg_files.map! { |file_name|
      Pathname(file_name).directory? ? file_name + "/**/*.rb" : file_name
    }
  end

  all_files = Rake::FileList["./spec/matest_specs/**/*_spec.rb"]
  files = arg_files || all_files
  puts "\nRuning tests for: #{ files.join(" ") }\n\n"

  system *["./bin/matest"].concat(files)
end

task :matest do
  arg_files = ENV["FILES"] && ENV["FILES"].split(/[\s,]+/)
  all_files = Rake::FileList["./spec/matest_specs/**/*_spec.rb"]
  files = arg_files || all_files
  puts "\nRuning tests for: #{ files.join(" ") }\n\n"

  system *["./bin/matest"].concat(files)
end
