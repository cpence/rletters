# -*- encoding : utf-8 -*-
require 'spec_helper'

SimpleCov.command_name 'spec:helpers' if defined?(SimpleCov) && RUBY_VERSION >= "1.9.0"

describe ApplicationHelper do
  
  describe '#render_footer_list' do
    # FIXME: Can't decide whether or not we want to test this.
  end
  
  describe '#render_static_partial' do
    context "when there is no custom content" do
      before(:all) do
        @dist_filename = Rails.root.join('app', 'views', 'static', '_testing.markdown.dist')
        @custom_filename = Rails.root.join('app', 'views', 'static', '_testing.markdown')
        
        File.open(@dist_filename, 'w') do |f|
          f.write('# Testing #')
        end
      end
      
      after(:all) do
        File.delete(@dist_filename)
      end
      
      it "should render the Markdown template" do
        helper.should_receive(:render).with({ :file => @dist_filename })
        helper.render_static_partial :testing
      end
    end
    
    context "when there is custom content" do
      before(:all) do
        @dist_filename = Rails.root.join('app', 'views', 'static', '_testing.markdown.dist')
        @custom_filename = Rails.root.join('app', 'views', 'static', '_testing.markdown')
        
        File.open(@dist_filename, 'w') do |f|
          f.write('# Testing #')
        end
        
        File.open(@custom_filename, 'w') do |f|
          f.write('# This is a Test #')
        end
      end
      
      after(:all) do
        File.delete(@dist_filename)
        File.delete(@custom_filename)
      end
      
      it "should render the custom Markdown template" do
        helper.should_receive(:render).with({ :file => @custom_filename })
        helper.render_static_partial :testing
      end
    end
  end
  
  describe '#t_md' do
    context "without a shortcut" do
      it "should render Markdown in translations" do
        I18n.backend.store_translations :en, :test_markdown => '# Testing #'
        
        html = helper.t_md(:test_markdown)
        html.should be
        html.should have_selector('h1', :content => 'Testing')
      end
    end

    context "with a shortcut" do
      before(:all) do
        I18n.backend.store_translations :en, :info => { :spectest => { :testing => '# Testing #' }}

        @custom_filename = Rails.root.join('app', 'views', 'info', 'spectest.html.haml')
        File.open(@custom_filename, 'w') do |f|
          f.write('= t_md(".testing")')
        end
      end

      after(:all) do
        File.delete(@custom_filename)
      end

      it "should render Markdown in translations" do
        render :template => 'info/spectest'
        rendered.should have_selector('h1', :content => 'Testing')
      end
    end
  end
  
end
