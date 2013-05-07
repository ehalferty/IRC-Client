WIN_WIDTH = 83
WIN_HEIGHT = 18


class ChatWindow < Curses::Window
    
    attr_accessor :bot, :buffer
    
    def initialize(conn, i)
        @conn = conn
        @buffer = []
        @position = 0
        @title = conn[:nick] + "@" + conn[:address] + "#" + conn[:channel]
        super(WIN_HEIGHT, WIN_WIDTH, (i/2) * WIN_HEIGHT, (i%2) * WIN_WIDTH)
        box("|", "-")
        highlight((i == 0))
        refresh
        @connection = Thread.new do
            run(conn, self)
        end
    end
    
    def highlight(b)
        if (b)
            color = HIGHLIGHTED
        else
            color = UNHIGHLIGHTED
        end
        attron(Curses.color_pair(color)) do
            setpos(0, 1)
            addstr(@title)
            refresh
        end
    end
    
    def scroll_up
        if (@position < (@buffer.length - 16))
            @position += 1
        end
        update()
    end
    
    def scroll_down
        if (@position > 0)
            @position -= 1
        end
        update()
    end
    
    def go_to_end
        @position = 0
        update()
    end
    
    def update()
        @buffer[@position,16].each_with_index do |b, i|
            setpos(16 - i, 0)
            addstr(b.ljust(WIN_WIDTH - 2))
        end
        refresh
    end
    
    def append_line(line)
        @buffer.unshift(line.to_s)
        if (@position != 0)
            @position += 1
        end
        update()
    end
    
    def append_lines(line)
        line.scan(/.{1,80}/).each { |line| append_line(line) }
    end
    
    def send_message(msg)
        @bot.irc.send("PRIVMSG #" + @conn[:channel] + " :" + msg + "\r\n")
        append_line("#{@conn[:nick]}: #{msg}")
    end
    
    def run(conn, s)
        @bot = Cinch::Bot.new do
            configure do |conf|
                conf.server = conn[:address]
                conf.port = conn[:port]
                conf.nick = conn[:nick]
                conf.user = conn[:nick]
                conf.realname = conn[:nick]
                conf.channels = ["#" + conn[:channel]]
            end
            
            loggers[0] = Cinch::Logger::FormattedLogger.new(
                File.open("/tmp/irc-client_#{conn[:address]}_#{conn[:nick]}.log", "a"))
            
            on :"372" do |m|
                s.append_lines(m.params[1])
            end
            
            on :leaving do |m, user|
                s.append_lines("*#{user} left.*")
            end
            
            on :join do |m|
                s.append_lines("*#{m.user} joined.*")
            end
            
            on :message do |m|
                s.append_lines("#{m.user.nick}: #{m.params[1]}")
            end
        end
        @bot.start
    end
end


