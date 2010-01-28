$testing = true
SPEC = File.dirname(__FILE__)
$:.unshift File.expand_path("#{Require.root}/lib")

# For use with rspec textmate bundle
def debug(object)
  puts "<pre>"
  puts object.pretty_inspect.gsub('<', '&lt;').gsub('>', '&gt;')
  puts "</pre>"
end
