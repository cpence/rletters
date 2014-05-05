# -*- encoding : utf-8 -*-

ActiveAdmin.register Documents::Category do
  menu parent: 'admin_settings'
  config.filters = false

  sortable tree: true,
           sorting_attribute: :sort_order,
           parent_method: :parent,
           children_method: :children,
           roots_method: :roots,
           collapsible: true

  index as: :sortable do
    label :name
    actions
  end

  form do |f|
    # Get the journals from Solr
    result = RLetters::Analysis::CountArticlesByField.new.counts_for(:journal_facet)
    journals = result.keys.compact

    f.inputs do
      f.input :name
      f.input :journals, as: :check_boxes, collection: journals, hidden_fields: false
    end
    f.actions
  end

  # :nocov:
  controller do
    def permitted_params
      params.permit(documents_category: [:parent_id, :sort_order, :name, journals: []])
    end
  end
  # :nocov:
end
