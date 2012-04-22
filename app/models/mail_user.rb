class MailUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :dns_resource

  validates_presence_of			:name
  validates_presence_of			:username
  validates_presence_of     :password,                   :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?

  #before_save :encrypt_password

  ## shorthand formatting functions

  # displays the domain for the mailbox
  # 
  def domain
    sprintf("%s%s%s", self.dns_resource.name, !self.dns_resource.name.empty? ? '.' : '', self.dns_resource.dns_zone.origin)
  end

  # displays the the full address of the mailbox
  #
  def address
    sprintf("%s@%s", self.username, self.domain)
  end  

  # Encrypts the user's password as a salted md5 hash
  #
  # * password - the raw password to be encrypted
  def encrypt(password)
    Crypt::crypt(password, :md5)
  end

  # Checks an unencrypted password against the encrypted one
  #
  # * password - the raw password to be checked
  def authenticated?(password)
    Crypt::check(password, self.password, :md5)
  end

	def encrypt_password
		return if self.password.blank?
		self.password = encrypt(password)
	end

	protected

		def password_required?
			self.password.blank? || !password.blank?
		end
end
