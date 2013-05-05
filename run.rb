require "curses"
require "yaml"
require "cinch"
require "pry"

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

connections_info = File.open("connections.yml") { |f| YAML::load(f) }
abort("This script only supports 4 windows.") if (connections_info.length > 4)
buffers = connections_info.map { |c| []}
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

            # Next window (ctrl-j)
        when '10'
            windows[selected_window].highlight(false)
            selected_window  = (selected_window + 1) % windows.length
            windows[selected_window].highlight(true)

            # Previous window (ctrl-k)
        when '11'
            windows[selected_window].highlight(false)
            selected_window  = (selected_window - 1) % windows.length
            windows[selected_window].highlight(true)

            # backspace
        when '127'
            com_win.buffer.chop!

            # return
        when "ret"
            cur_win.send_message(com_win.buffer)
            com_win.buffer = ""
            
            # Anything else
        when /[[:print:]]/
            com_win.buffer << key
        end
    end
ensure
    Curses.close_screen
end




