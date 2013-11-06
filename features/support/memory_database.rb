# -*- encoding : utf-8 -*-

# Load the DB schema, since we're using in-memory SQLite
load Rails.root.join('db', 'schema.rb')

# Seed the DB.  I know that people object to this sort of thing, but I want
# things like the standard package of CSL styles to be available without
# my having to write giant XML CSL-style factories.
load Rails.root.join('db', 'seeds.rb')
