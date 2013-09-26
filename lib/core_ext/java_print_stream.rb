# -*- encoding : utf-8 -*-
require 'java'

# In JRuby 1.7, java.io.PrintStream doesn't accept the String class anymore,
# so alias it to fix the bind-it library.
java_import java.io.PrintStream
class PrintStream
  java_alias(:write, :print, [java.lang.String])
end
