# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec, cmd: "bundle exec rspec --format documentation" do
  require "ostruct"

  # Generic Ruby apps
  rspec = OpenStruct.new
  rspec.spec = ->(m) { "spec/#{m}_spec.rb" }
  rspec.spec_dir = "spec"
  rspec.spec_helper = "spec/spec_helper.rb"


#  watch(%r{^lib/models/ib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
#  watch(%r{^lib/ib/messages/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
#  watch(%r{^lib/ib/symbols/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }

  watch(%r{^ib-technical-analysis/(.+)\.rb$})  { |m| "spec/ib-technical-analysis/#{m[1]}_spec.rb" }
#  watch(%r{^models/(.+)\.rb$})  { |m| "spec/models/#{m[1]}_spec.rb" }
  watch(%r{^spec/lib/.+_spec\.rb$})
  watch('spec/spec_helper.rb')  { "spec" }
#  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
end

