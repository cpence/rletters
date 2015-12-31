
ActiveAdmin.register Admin::FeatureFlags do
  actions :index, :update, :edit
  menu parent: 'Settings'

  config.filters = false
  config.batch_actions = false

  permit_params :var, :value

  controller do
    def update
      var = permitted_params.dig(:admin_feature_flags, :var)&.to_sym
      fail ActiveRecord::RecordNotFound unless var
      value = permitted_params.dig(:admin_feature_flags, :value)
      fail ActiveRecord::RecordNotFound unless value

      flag_def = Admin::FeatureFlags.all_features.detect { |d| d[:var] == var }
      fail ActiveRecord::RecordNotFound unless flag_def

      case flag_def[:type]
      when :boolean
        Admin::FeatureFlags[var] = (value == '1')
      else
        Admin::FeatureFlags[var] = value
      end

      update! do |format|
        format.html { redirect_to collection_path }
      end
    end

    def scoped_collection
      Admin::FeatureFlags.all_features.each do |flag|
        # Make sure that all the flags have entries in the database
        Admin::FeatureFlags[flag[:var]] = Admin::FeatureFlags[flag[:var]]
      end

      Admin::FeatureFlags.thing_scoped
    end
  end

  index do
    column :var
    column :value
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    var = admin_feature_flags.var.to_sym
    f.inputs "#{Admin::FeatureFlags.model_name.human}: #{var}" do
      flag_def = Admin::FeatureFlags.all_features.detect { |d| d[:var] == var }
      next unless flag_def

      f.input :value, as: flag_def[:type]
      f.input :var, as: :hidden
    end
    f.actions
  end
end
