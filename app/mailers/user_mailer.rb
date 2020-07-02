class UserMailer < ApplicationMailer

  def send_mail(email)
    mail(:to => email, :subject => "Earn $10 when you Sign Up" ) do |format|
      format.text
      format.html
    end
  end
end
