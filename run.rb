require "curses"
require "yaml"
require "cinch"
#require "pry"

require_relative "CommandWindow"
require_relative "ChatWindow"

status = ""
buffer = ""
selected_window = 0
Curses.init_screen
Curses.start_color

HIGHLIGHTED = 32
Curses.init_pair(HIGHLIGHTED, Curses::COLOR_BLACK, Curses::COLOR_WHITE)
UNHIGHLIGHTED = 33
Curses.init_pair(UNHIGHLIGHTED, Curses::COLOR_WHITE, Curses::COLOR_BLACK)
MOTD = 34
Curses.init_pair(MOTD, Curses::COLOR_RED, Curses::COLOR_BLACK)

abort("Usage: ruby $0 <connections listing file>.yml") if (!ARGV[0])
connections_info = File.open(ARGV[0]) { |f| YAML::load(f) }
abort("This script only supports 4 windows.") if (connections_info.length > 4)
windows = connections_info.map.with_index { |c, i| ChatWindow.new(c, i) }

#Curses.close_screen
#binding.pry

com_win = CommandWindow.new
com_win.refresh
begin
    Curses.raw
    Curses.noecho
    Curses.stdscr.keypad(true)
    loop do
        cur_win = windows[selected_window]
        com_win.update()
        key = com_win.fixed_getch()
        case key

            # scroll up
        when '27[A'
            cur_win.scroll_up()

            # scroll down
        when '27[B'
            cur_win.scroll_down()

            # Page up
        when '27[5~'
            16.times { cur_win.scroll_up() }

            # Page down
        when '27[6~'
            16.times { cur_win.scroll_down() }

            # Go to end
        when '27OF'
            cur_win.go_to_end()

            # escape
        when '27'
            com_win.status = "escape"

            # quit (ctrl-q)
        when '17'
            abort()

            # Next window (ctrl-down)
        when "27[1;5B"
            windows[selected_window].highlight(false)
            selected_window  = (selected_window + 1) % windows.length
            windows[selected_window].highlight(true)

            # Previous window (ctrl-up)
        when "27[1;5A"
            windows[selected_window].highlight(false)
            selected_window  = (selected_window - 1) % windows.length
            windows[selected_window].highlight(true)

            # backspace
        when '127'
            com_win.buffer.chop!

            # return
        when "ret"
            if (com_win.buffer.start_with? "/")
                tokens = com_win.buffer[1..-1].split
                case tokens[0]
                when "save"
                    connections_info.each_with_index do |conn, i|
                        filename = Time.now.strftime("saved-#{conn[:address]}-#{conn[:channel]}-%Y%m%d-%H%M%S")
                        File.open(filename, 'w') { |f| f.write(windows[i].buffer.join("\n")) }
                    end
                else
                end
            else
                cur_win.send_message(com_win.buffer) if (com_win.buffer != "")
            end
            com_win.buffer = ""
            
            # Anything else
        when /[[:print:]]/
            com_win.buffer << key
        end
    end
ensure
    Curses.close_screen
end




