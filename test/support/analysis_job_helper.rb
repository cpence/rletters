
module AnalysisJobHelper
  def test_should_call_finish_and_send_email
    mailer_ret = flexmock()
    mailer_ret.should_receive(:deliver_later).with(queue: :maintenance)
    flexmock(UserMailer).should_receive(:job_finished_email)
      .and_return(mailer_ret)

    perform

    refute_nil @task.reload.finished_at
  end
end
