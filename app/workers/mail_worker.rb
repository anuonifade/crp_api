class SendMailWorker
  include SideKiq::Worker
  sidekiq_options retry: false

  def perform(emails)
    emails.each do |email|
      UserMailer.with(email: email).deliver_now
    end
  end
end
