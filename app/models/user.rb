class User < ActiveRecord::Base
  has_many :dns_zones
  has_many :mail_users
  has_many :web_sites

  validates_presence_of     :username
  validates_presence_of     :password,                   :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :username, :within => 3..40
  validates_uniqueness_of   :username, :case_sensitive => false

  before_save :encrypt_password

  ##
  ## Authentication 
  ##

  # Checks the given credentials for logging the User in.
  #
  # * username - the account name.
  # * password - the password.
  def self.authenticate(username, password)
    u = find_by_username(username)
    u && u.authenticated?(password) ? u : nil
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

  ##
  ## DNS 
  ##
  def domains
    DnsZone.find(:all, :conditions => [ "user_id =?", self.id], :order => 'origin')
  end

  protected

    # Create a new encrypted password
    #
    def encrypt_password
      return if self.password.blank?
      self.password = encrypt(password)
    end
    
    def password_required?
      self.password.blank? || !password.blank?
    end
end
