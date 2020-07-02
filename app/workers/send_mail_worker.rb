class SendMailWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(emails)
    emails.each do |email|
      UserMailer.send_mail(email).deliver_later
    end
  end
end
