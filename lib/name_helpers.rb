# -*- encoding : utf-8 -*-

# Code for formatting the names of authors
module NameHelpers
  # Turn an author's name into a set of Lucene queries
  #
  # When a user searches for an author by name, we want some degree of
  # fuzziness in our search results.  This function calls
  # +NameHelpers.query_for_names+ with (1) just the first and last name, and
  # (2) the first, middle (if provided), and last names.  It also takes into
  # account the possiblity of the user providing a compact string of initials.
  #
  # @api public
  # @param [String] a the name to split
  # @return [String] the Lucene query for this author name
  # @example Add a Lucene query for W. Shatner
  #   params[:q] += "authors:(#{name_to_lucene('W. Shatner')})"
  def self.name_to_lucene(a)
    parts = BibTeX::Names.parse(a)[0]

    # Construct the last name we'll use, which is last name with von part
    # and suffix w/o period
    last = ''
    last += "#{parts.prefix} " if parts.prefix
    last += parts.last
    last += " #{parts.suffix.chomp('.')}" if parts.suffix

    # Quick out: if there's no first name, bail
    return "\"#{last}\"" unless parts.first

    # Strip periods from parts.first and split
    first = parts.first.gsub('.', '')
    first_names = first.split(' ')

    # Flatten out sequences of initials
    first_names.map! do |n|
      if n == n.upcase
        # All uppercase, so assume it's initials
        n.chars.to_a
      else
        n
      end
    end
    first_names.flatten!

    # Now, construct queries for "First Last" and "First (all middles) Last"
    queries = []
    queries.concat(NameHelpers.query_for_names([first_names[0]], last))
    if first_names.count > 1
      queries.concat(NameHelpers.query_for_names(first_names, last))
    end

    # Compose these together and return
    "(#{queries.join(' OR ')})"
  end

  private

  # Create Lucene queries for the given names
  #
  # This function handles the vagaries of the formatting of an individual set
  # of names for Lucene.  There are three basic processes that this function
  # performs:
  #
  # 1. If a name is submitted by the user as a single letter, it will be
  #    searched with a wildcard.
  # 2. If a name is submitted by the user *not* as a single letter, it will
  #    result in two queries, one with the full name and one with an initial.
  # 3. If multiple initials in a row are present, then we combine them into
  #    a single search term.
  #
  # @api private
  # @param [Array<String>] first list of first/middle names to use
  # @param [String] last last name to use
  # @return [Array<String>] Lucene queries for this set of names
  # @example Query without wildcards
  #   NameHelpers.query_for_names [ 'First' ], 'Last'
  #   #=> ['"F Last"', '"First Last"']
  # @example Query with wildcards
  #   NameHelpers.query_for_names [ 'F' ], 'Last'
  #   #=> ['"F* Last"']
  # @example Query with multiple forms produced
  #   NameHelpers.query_for_names [ 'First', 'Middle' ], 'Last'
  #   #=> ['"First Middle Last"', '"F Middle Last"',
  #   #    '"First M Last"', '"F M Last"', '"FM Last"']
  def self.query_for_names(first, last)
    # Create an array of all the forms of each name
    first_name_forms = []

    first.each do |f|
      if f.length == 1
        # Just an initial, search it with a wildcard
        first_name_forms << ["#{f}*"]
      else
        # A name, search it as itself and as an initial, but without
        # a wildcard.
        first_name_forms << [f, f[0]]
      end
    end

    # Form the list of all the names we're actually going to use
    first_name_forms_0 = first_name_forms.shift
    names = first_name_forms_0.product(*first_name_forms).map { |n| n << last }

    # Step through these and create the combined-initials queries
    new_names = []
    names.each do |name|
      next if name.count == 2

      # We want to be able to combine "First M M Last" to "First MM Last".
      # So loop over subsequences of all size == 1 and <= number of first
      # names.
      (2..(name.count - 1)).each do |n|
        name.each_with_index do |p, i|
          # See if a part of the array at index i with size n is all initials
          portion = name[i, n]
          next unless portion.all? { |x| x.length == 1 }

          # Create a new name with this portion merged
          new_names << [name[0...i], portion.join, name[(i + n)..-1]].flatten
        end
      end
    end

    names.concat(new_names)

    # Return the queries
    names.map { |na| "\"#{na.join(' ')}\"" }
  end
end
