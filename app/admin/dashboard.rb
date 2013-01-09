# -*- encoding : utf-8 -*-
ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    
    columns do
      column do
        panel "Newest Datasets" do
          table_for Dataset.order("created_at desc").limit(5) do
            column :name do |dataset|
              link_to dataset.name, [:admin, dataset]
            end
            column :user do |dataset|
              link_to dataset.user.name, [:admin, user]
            end
            column :created_at
          end
        end
        
        panel "Backend Information" do
          h4 "Database"
          
          ul do
            solr_query = {}
            solr_query[:q] = '*:*'
            solr_query[:qt] = 'precise'
            solr_query[:rows] = 5
            solr_query[:start] = 0
    
            solr_response = Solr::Connection.find solr_query
            
            if (solr_response["response"] &&
                solr_response["response"]["numFound"])
              li "Database size: #{solr_response["response"]["numFound"]} items"
            else
              li "Database size: cannot query!"
            end
            
            li "Local database latency: #{solr_response['responseHeader']['QTime']} ms"
          end
          
          h4 "Solr Server"
          
          ul do
            solr_info = Solr::Connection.info

            li "Solr #{solr_info['lucene']['solr-spec-version']}, Lucene #{solr_info['lucene']['lucene-spec-version']}"
            li "Java #{solr_info['jvm']['version']}"
            
            li "Memory: #{solr_info['jvm']['memory']['used']} used, with #{solr_info['jvm']['memory']['free']} free of #{solr_info['jvm']['memory']['total']}; #{solr_info['jvm']['memory']['max']} max"
          end
        end
      end
      
      column do
        panel "Newest Analysis Tasks" do
          table_for AnalysisTask.order("created_at desc").limit(10) do
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
        
        panel "Recently Seen Users" do
          table_for User.order("last_sign_in_at desc").limit(5) do
            column :name do |user|
              link_to user.name, [:admin, user]
            end
            column :last_sign_in_at
          end
        end
      end
    end

  end
end
