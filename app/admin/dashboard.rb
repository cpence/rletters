
AdminEnvVar = Struct.new(:name, :value)
ENVIRONMENT_VARIABLES_TO_PRINT = [
  # Our configuration
  'APP_NAME', 'APP_EMAIL', 'APP_MAIL_DOMAIN',
  'DATABASE_URL', 'SOLR_URL', 'SOLR_TIMEOUT',
  'NLP_TOOL_PATH', 'GOOGLE_ANALYTICS_KEY',
  'VERBOSE_LOGS', 'MAILER_PREVIEWS',
  # Important/interesting Ruby information, if available
  'RBENV_VERSION', 'RUBYOPT', 'RUBYLIB', 'GEM_PATH', 'GEM_HOME',
  'BUNDLE_BIN_PATH', 'BUNDLE_GEMFILE',
  # Rails information
  'RACK_ENV', 'RAILS_ENV'
]

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    columns do
      column do
        panel I18n.t('admin.dashboard.new_datasets') do
          table_for Dataset.order('created_at desc').limit(5) do
            column :name do |dataset|
              link_to dataset.name, [:admin, dataset]
            end
            column :user do |dataset|
              link_to dataset.user.name, [:admin, dataset.user]
            end
            column :created_at
          end
        end

        panel I18n.t('admin.dashboard.backend') do
          h4 I18n.t('admin.dashboard.database')

          ul do
            corpus_size = RLetters::Solr::CorpusStats.new.size
            ping = RLetters::Solr::Connection.ping

            if corpus_size && ping
              li I18n.t('admin.dashboard.db_size', count: corpus_size)
              li I18n.t('admin.dashboard.latency', count: ping)
            else
              li I18n.t('admin.dashboard.connection_failed')
            end
          end

          solr_info = RLetters::Solr::Connection.info

          if solr_info['lucene'] && solr_info['jvm']
            h4 I18n.t('admin.dashboard.solr')

            ul do
              li I18n.t('admin.dashboard.solr_version',
                        solr_ver: solr_info['lucene']['solr-spec-version'],
                        lucene_ver: solr_info['lucene']['lucene-spec-version'])
              li I18n.t('admin.dashboard.java_version',
                        java_ver: solr_info['jvm']['version'])

              li I18n.t('admin.dashboard.memory_info',
                        used: solr_info['jvm']['memory']['used'],
                        free: solr_info['jvm']['memory']['free'],
                        total: solr_info['jvm']['memory']['total'],
                        max: solr_info['jvm']['memory']['max'])
            end
          end
        end
      end

      column do
        panel I18n.t('admin.dashboard.new_tasks') do
          table_for Datasets::Task.order('created_at desc').limit(10) do
            column :name do |task|
              link_to task.name, [:admin, task]
            end
            column :job_type
            column :dataset do |task|
              link_to task.dataset.name, [:admin, task.dataset]
            end
            column :failed
          end
        end

        panel I18n.t('admin.dashboard.recent_users') do
          table_for User.order('last_sign_in_at desc').limit(5) do
            column :name do |user|
              link_to user.name, [:admin, user]
            end
            column :last_sign_in_at
          end
        end
      end
    end

    panel 'Current Environment' do
      env_vars = ENV.map do |k, v|
        (ENVIRONMENT_VARIABLES_TO_PRINT.include?(k.to_s) &&
          AdminEnvVar.new(k.to_s, v.to_s)) || nil
      end
      env_vars.compact!
      env_vars.sort_by! { |var| ENVIRONMENT_VARIABLES_TO_PRINT.index(var.name) }

      table_for env_vars do
        column 'Variable', :name
        column 'Value', :value
      end
    end
  end
end
