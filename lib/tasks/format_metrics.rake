# -*- encoding : utf-8 -*-
require 'rouge'
require 'nokogiri'
require 'fileutils'

namespace :metrics do
  desc 'Generate a fancy report of all the code metrics run so far'
  task :generate do
    # Get all the source against which we'll run any metrics
    ruby_files = Dir['{app,config,db,lib,spec}/**/*.{rb,rake,god}']
    ruby_files.delete('db/schema.rb')
    ruby_files << 'Gemfile'

    # Run it through the pretty-printer first
    formatter = Rouge::Formatters::HTML.new(
      css_class: 'highlight',
      line_numbers: true
    )
    lexer = Rouge::Lexers::Ruby.new
    theme = Rouge::Themes::Base16
    ruby_files.each do |in_file|
      metric_filename = File.join('doc', 'metrics', in_file + '.html')

      FileUtils.mkdir_p(File.dirname(metric_filename))
      File.open(metric_filename, 'w') do |out_file|
        out_file.write(<<-eos
<!DOCTYPE html>
<head>
  <meta charset="utf-8">
  <title>Code Metrics: #{in_file}</title>
  <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css">
  <style type="text/css">
    body { font-family: Helvetica, Arial, sans-serif; }
    h1 { margin-bottom: 0; }
    .sep { text-align: right; text-transform: uppercase; margin-bottom: 3em; color: #d0d0d0; }
    pre { font-family: "Menlo", "DejaVu Sans Mono", "Bitstream Vera Sans Mono", "Inconsolata", "Courier New", Courier, monospace; font-size: 80%; line-height: 1.4; }
    .highlight td.gutter { background-color: #fff; }
    .lineno { color: #fff; padding: 0 6px; }
    a.lineno { display: block; text-decoration: none; }
    #{theme.render(:scope => '.highlight')}
    .ui-widget { font-size: 80%; }
  </style>
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
  <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"></script>
  <script type="text/javascript">
  function showDialog(id) {
    $(id).dialog({
      width: 600,
      height: 400
    });
  }
  </script>
</head>
<body>
<h1>Metrics for #{in_file}</h1>
eos
        )

        out_file.write(formatter.format(lexer.lex(IO.read(in_file))))
        out_file.write('</body></html>')
      end
    end

    # Next: read in each of the metrics files and put them in a giant hash
    # of stuff
    metric_data = { }

    if File.exist? File.join('doc', 'metrics', 'rubocop.txt')
      current_dir = Dir.pwd
      File.open(File.join('doc', 'metrics', 'rubocop.txt')).each_line do |l|
        next unless l.start_with? '/'

        matches = l.match(/#{current_dir}\/(.*):(\d*):\d*: (.*)/)
        unless matches
          puts "WARNING: Could not read Rubocop line #{l}"
          next
        end

        metric_data[matches[1]] ||= { }
        metric_data[matches[1]][Integer(matches[2])] ||= []
        metric_data[matches[1]][Integer(matches[2])] << '<strong>RuboCop: </strong>' + matches[3]
      end
    end

    if File.exist? File.join('doc', 'metrics', 'yardstick.txt')
      File.open(File.join('doc', 'metrics', 'yardstick.txt')).each_line do |l|
        matches = l.match(/(.*):(\d*): (.*)/)
        next unless matches

        metric_data[matches[1]] ||= { }
        metric_data[matches[1]][Integer(matches[2])] ||= []
        metric_data[matches[1]][Integer(matches[2])] << '<strong>Yardstick: </strong>' + matches[3]
      end
    end

    if File.exist? File.join('doc', 'metrics', 'excellent.html')
      excellent_file = File.open(File.join('doc', 'metrics', 'excellent.html'))
      excellent_doc = Nokogiri::HTML::Document.parse(excellent_file)
      excellent_doc.css('#results .file').each do |file|
        filename = file.at_css('dl dt').content

        problems = file.css('dl dd').each do |p|
          line = Integer(p.at_css('.lineNumber .number').content)
          p.css('span').remove
          problem = p.content.strip

          metric_data[filename] ||= { }
          metric_data[filename][line] ||= []
          metric_data[filename][line] << '<strong>Excellent: </strong>' + problem
        end
      end
    end

    if File.exist? File.join('doc', 'metrics', 'railsbp.html')
      railsbp_file = File.open(File.join('doc', 'metrics', 'railsbp.html'))
      railsbp_doc = Nokogiri::HTML::Document.parse(railsbp_file)
      railsbp_doc.css('table.result tbody tr').each do |row|
        filename = row.at_css('td.filename').content.strip
        line = Integer(row.at_css('td.line').content.strip)
        problem = row.at_css('td.message a').content.strip

        metric_data[filename] ||= { }
        metric_data[filename][line] ||= []
        metric_data[filename][line] << '<strong>rails_best_practices: </strong>' + problem
      end
    end

    # FIXME: Brakeman, once its Rake task has been fixed.

    # Compute the percentiles for counts for files
    file_problems = { }
    metric_data.each do |filename, lines|
      count = 0
      lines.each { |line, problems| count += problems.count }
      file_problems[filename] = count
    end

    file_counts = file_problems.values.sort
    file_percentiles = [
      file_counts[(file_counts.count * 0.5).ceil],
      file_counts[(file_counts.count * 0.9).ceil]
    ]

    COLORS = ['#f4bf75', '#d28445', '#ac4142', '#90a959']

    # Finally, add the data to the HTML files
    ruby_files.each do |in_file|
      data = metric_data[in_file] || { }
      filename = File.join('doc', 'metrics', in_file + '.html')
      html = IO.read(filename)

      data.each do |line, problems|
        if problems.count <= 1
          bg_color = COLORS[0]
        elsif problems.count <= 3
          bg_color = COLORS[1]
        else
          bg_color = COLORS[2]
        end

        # Sure, we can parse HTML with sed.
        html.sub!(
          "<div class=\"lineno\">#{line}</div>",
          "<a class=\"lineno\" style=\"background-color: #{bg_color}\" href=\"#\" onclick=\"showDialog('##{line}-dialog'); return false;\">(#{problems.count}) #{line}</a>" \
          "<div style=\"display: none\" id=\"#{line}-dialog\" title=\"Problems on line #{line}\"><ul><li>#{problems.join('</li><li>')}</li></ul></div>"
        )
      end

      # All the other lines are green (for now...)
      html.gsub!('<div class="lineno">', "<div class=\"lineno\" style=\"background-color: #{COLORS[3]}\">")

      # And colorize the header based on the file status
      if file_problems[in_file].nil?
        head_color = COLORS[3]
      elsif file_problems[in_file] < file_percentiles[0]
        head_color = COLORS[0]
      elsif file_problems[in_file] < file_percentiles[1]
        head_color = COLORS[1]
      else
        head_color = COLORS[2]
      end
      html.sub!('<h1>', "<h1 style=\"color: #{head_color}\">")
      html.sub!('</h1>', "</h1><div class=\"sep\">#{file_problems[in_file] || 0} issues…</div>")

      File.open(filename, 'w') { |f| f.write(html) }
    end

    # Generate the file listing
    File.open(File.join('doc', 'metrics', 'listing.html'), 'w') do |f|
      f.write(<<-eos
<!DOCTYPE html>
<head>
  <meta charset="utf-8">
  <title>File Listing</title>
  <style type="text/css">
    body { font-family: Helvetica, Arial, sans-serif; }
    ul { list-style-type: none; margin: 4px; padding: 0; }
    a, a:link, a:visited, a:active { color: #6a9fb5; font-size: 70%; }
  </style>
</head>
<body>
<ul>
eos
      )

      ruby_files.each do |rb|
        if file_problems[rb].nil?
          link_color = COLORS[3]
        elsif file_problems[rb] < file_percentiles[0]
          link_color = COLORS[0]
        elsif file_problems[rb] < file_percentiles[1]
          link_color = COLORS[1]
        else
          link_color = COLORS[2]
        end

        f.write("<li><a href='#{rb}.html' target='main' style='color: #{link_color}'>#{rb}</a></li>")
      end

      f.write('</ul></body></html>')
    end

    # Generate the frameset (teehee, cringe)
    File.open(File.join('doc', 'metrics', 'index.html'), 'w') do |f|
      f.write(<<-eos
<!DOCTYPE html>
<head>
  <meta charset="utf-8">
  <title>RLetters Code Metrics</title>
  <style type="text/css">
    body { font-family: Helvetica, Arial, sans-serif; }
  </style>
</head>
<frameset framespacing="0" cols="250,*" frameborder="0" noresize>
  <frame name="left" src="listing.html" target="main">
  <frame name="main" src="Gemfile.html" target="main">
</frameset>
</html>
eos
      )
    end
  end

  desc 'Copy the metrics to the gh-pages folder'
  task :publish, :path do |t, args|
    path = args[:path] || File.join('..', 'gh-pages')
    unless Dir.exist? File.join(path, '.git')
      abort 'ERROR: You must specify the path to a checkout of the gh-pages repository (default: ../gh-pages/)'
    end

    FileUtils.rm_rf(File.join(path, 'metrics'))
    FileUtils.cp_r(File.join('doc', 'metrics'), path)

    puts 'Finished! Now commit/push the changes to the gh-pages repository.'
  end
end
