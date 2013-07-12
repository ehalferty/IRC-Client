class CommandWindow < Curses::Window
    
    attr_accessor :buffer, :status
    
    def initialize
        super(2, 160, WIN_HEIGHT * 2, 0)
        @buffer = ""
        @status = ""
    end
    
    # getch for Curses doesn't work well with some multi-byte keycodes.
    # This is a workaround, and also kind of terrible. Eventually I should
    # fix Curses, but then I would have to make decisions about how to map
    # those keys to codes, which could cause problems for anyone who is
    # relying on the current behavior, and possibly unaware of the fact.
    def fixed_getch
        key = self.getch.to_s
        if (key == "10")
           key = "ret" 
        elsif (key == "27")
            self.timeout = 0
            key2 = self.getch.to_s
            if (key2 == "O")
                key += key2 + self.getch.to_s
            elsif (key2 == "[")
                key3 = self.getch.to_s
                if (key3 == "1")
                    key += key2 + key3 + self.getch.to_s + self.getch.to_s + self.getch.to_s
                else
                    key += key2 + key3 + self.getch.to_s
                end
            else
                key += key2
            end
            self.timeout = -1
        end
        return key
    end
    
    def update()
        setpos(0, 0)
        addstr(@status.ljust(160))
        setpos(1, 0)
        addstr(">" + @buffer.ljust(160))
        refresh
    end
end
