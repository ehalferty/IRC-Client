class CommandWindow < Curses::Window
    def fixed_getch
        key = self.getch.to_s
        if (key == "27")
            self.timeout = 0
            key2 = self.getch.to_s
            if (key2 == "O")
                key += key2 + self.getch.to_s
            elsif (key2 == "[")
                key += key2 + self.getch.to_s + self.getch.to_s
            else
                key += key2
            end
            self.timeout = -1
        end
        return key
    end
end
