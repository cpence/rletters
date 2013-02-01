# -*- encoding : utf-8 -*-

unless YAML.respond_to? :safe_load_file
  module YAML
    # Load a YAML file, without executing arbitrary Ruby code
    #
    # @param [String] filename name of file to load
    # @return YAML serialized object
    def self.safe_load_file(filename)
      File.open(filename, 'r:bom|utf-8') { |f| self.safe_load f }
    end
  end
end
