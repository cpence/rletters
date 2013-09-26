# -*- encoding : utf-8 -*-

# Set the right Cocaine runner on JRuby
if RUBY_PLATFORM == 'java'
  Cocaine::CommandLine.runner = Cocaine::CommandLine::PopenRunner.new
end
