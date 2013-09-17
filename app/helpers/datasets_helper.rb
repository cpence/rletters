# -*- encoding : utf-8 -*-

# Markup generators for the datasets controller
module DatasetsHelper
  # Render a partial from a job
  def render_job_partial(klass, view)
    # Find the partial
    klass.view_paths.each do |p|
      path = File.join(p, "_#{view}.html.haml")
      if File.exist? path
        return render file: path
      end
    end

    render inline: "<p><strong>ERROR: Cannot find job view #{view} for class #{klass}"
  end
end
