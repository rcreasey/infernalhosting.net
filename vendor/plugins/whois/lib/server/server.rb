module Server

    # Define if the module has or not the Class in this module
    def self.class_exist? str
        begin
            self.class_eval str
            return true
        rescue NameError
            return false
        end
    end

    # Class For define a model of Server
    class Server
        attr_reader :server
        
    end
    
    # Class for the server Afrinic
    class Afrinic < Server
    
        def initialize
            @server = 'whois.afrinic.net'
        end
    end

    # Class for the Server Apnic
    class Apnic < Server

        def initialize
            @server = 'whois.apnic.net'
        end
    end

    # Class for the Server Ripe
    class Ripe < Server
        def initialize
            @server = 'whois.ripe.net'
        end
    end

    # Class for the Server Arin
    class Arin < Server
        def initialize
            @server = 'whois.arin.net'
        end
    end

    # Class for the Server Lacnic
    class Lacnic < Server
        def initialize
            @server = 'whois.lacnic.net'
        end
    end

    # Class for Server whois.nic.or.kr
    class Nicor < Server
        def initialize
            @server = 'whois.nic.or.kr'
        end
    end
    
    # Class for Server whois.nic.ad.jp
    class Nicad < Server
        def initialize
            @server = 'whois.nic.ad.jp'
        end
    end

    # Class for Server whois.nic.br
    class Nicbr < Server
        def initialize
            @server = 'whois.nic.br'
        end
    end
        
end
