# -*- encoding : utf-8 -*-

if RUBY_PLATFORM == 'java'
  require 'java'

  # In JRuby 1.7, java.io.PrintStream doesn't accept the String class anymore,
  # so alias it to fix the bind-it library.
  java_import java.io.PrintStream

  # This fix comes from Jenkins on GH:
  # https://github.com/jenkinsci/jenkins.rb/issues/86
  class PrintStream
    java_alias(:write, :print, [java.lang.String])
  end
end
