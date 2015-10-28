
ActiveAdmin.register Documents::Category do
  menu parent: 'admin_settings'
  config.filters = false

  permit_params :parent_id, :sort_order, :name, journals: []

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
    f.semantic_errors(*f.object.errors.keys)

    # Get the journals from Solr
    ret = RLetters::Analysis::CountArticlesByField.call(field: :journal_facet)
    journals = ret.counts.keys.compact

    f.inputs do
      f.input :name
      f.input :journals, as: :check_boxes, collection: journals, hidden_fields: false
    end
    f.actions
  end
end
