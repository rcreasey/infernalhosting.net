class Registrar 

  # ryan@kaneda.net
  # parent id 999999998
  # demo url: http://api.onlyfordemo.net/anacreon/servlet/APIv3
  # retail url: http://www.myorderbox.com/anacreon/servlet/APIv3


  class ConnectionFactory
    def initialize
    end

  end

  def initialize
    @factory = ConnectionFactory.new
  end

end
