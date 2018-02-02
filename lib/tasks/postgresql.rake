# h/t to: https://gist.github.com/rietta/7898366
#
# PostgreSQL writes two optional commands to the database schema
# file, called db/structure.sql, that can only be run as a root
# database user.  These are not needed actually, so comment them
# out automatically
#
# CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
# COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
#
namespace :db do
  namespace :structure do
    desc 'Comment out the plpgsql lines from structure.sql so that a non-root user can create the test database'
    task :fix_plpgsql do

      lines_to_strike = [
          'CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;',
          "COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';",
      ]

      schema_file = File.join(File.dirname(__FILE__), '..', '..', 'db', 'structure.sql')
      if File.exist?(schema_file) and (input = File.open(schema_file))
        # Create a temp file, read through the original, commenting out the target lines.
        lines = Array.new
        line_count = 0
        input.each_line do |line|
          if line
            line_count += 1
            if lines_to_strike.include?(line.strip)
              lines << "-- The following was commented out by rake db:structure:fix_plpgsql\n"
              lines << '-- ' + line
            else
              lines << line
            end
          end
        end # each

        input.close

        if lines.count > line_count
          # Lines were commented out, so write the new content to the file
          File.write(schema_file, lines.join)
        else
          # No lines were commented out, so there is no need to rewrite the file
          STDERR.puts "No changes are needed to #{schema_file}, it's left unchanged."
        end


      end

    end # task
  end # namespace
end # namespace

# Inform Rake that this should be run every time rake db:structure:dump is run
Rake::Task['db:structure:dump'].enhance do
  Rake::Task['db:structure:fix_plpgsql'].invoke
end
