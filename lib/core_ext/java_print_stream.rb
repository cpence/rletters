# -*- encoding : utf-8 -*-
require 'java'

java_import java.io.PrintStream
class PrintStream
  java_alias(:write, :print, [java.lang.String])
end
