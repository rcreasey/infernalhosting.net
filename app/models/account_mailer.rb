class AccountMailer < ActionMailer::Base
  def signup_notification(account)
    setup_email(account)
    @subject    += 'Please activate your new account'
    @body[:url]  = "https://infernalhosting.net/activate/#{account.activation_code}"
  end
  
  def activation(account)
    setup_email(account)
    @subject    += 'Your account has been activated!'
    @body[:url]  = 'http://infernalhosting.net/'
  end
  
  protected
    def setup_email(account)
      @recipients  = "#{account.email_address}"
      @from        = "signup@infernalhosting.net"
      @subject     = "[infernalhosting.net] "
      @sent_on     = Time.now
      @body[:account] = account
    end
end
