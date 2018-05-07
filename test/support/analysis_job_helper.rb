# frozen_string_literal: true

module AnalysisJobHelper
  def test_should_call_finish_and_send_email
    mailer_ret = mock
    mailer_ret.expects(:deliver_later).with(queue: :maintenance)
    UserMailer.expects(:job_finished_email).returns(mailer_ret)

    perform

    refute_nil @task.reload.finished_at
  end

  def test_available_should_respect_feature_flag
    env_variable = self.class.name.underscore.sub('_test', '').upcase
    env_variable << '_DISABLED'

    class_name = self.class.name.sub('Test', '')
    klass = class_name.constantize

    ENV[env_variable] = '1'
    old_ntp = ENV['NLP_TOOL_PATH']
    ENV['NLP_TOOL_PATH'] = 'yes'

    refute klass.available?

    ENV.delete(env_variable)
    ENV['NLP_TOOL_PATH'] = old_ntp
  end
end
