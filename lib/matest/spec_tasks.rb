task :spec do
  arg_files = (ENV["FILES"] && ENV["FILES"].split(/[\s,]+/)) || [ENV["SPEC"]]
  if arg_files
    arg_files.map! { |file_name|
      path = Pathname(file_name.to_s).expand_path
      unless Pathname(file_name.to_s.split(":").first.to_s).exist?
        raise "Spec file not found: #{file_name.inspect}"
      end
      path.directory? ? path.to_s + "/**/*.rb" : path.to_s
    }
  end

  all_files = Rake::FileList["./spec/**/*_spec.rb"]
  files = arg_files || all_files
  puts "\nRuning tests for: #{ files.join(" ") }\n\n"

  system *["matest"].concat(files)
end
