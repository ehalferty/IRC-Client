require "curses"
require "yaml"
require "cinch"
require_relative "CommandWindow"
require_relative "ChatWindow"

status = ""
selected_window = 0
Curses.init_screen
Curses.start_color

HIGHLIGHTED = 32
Curses.init_pair(HIGHLIGHTED, Curses::COLOR_BLACK, Curses::COLOR_WHITE)
UNHIGHLIGHTED = 33
Curses.init_pair(UNHIGHLIGHTED, Curses::COLOR_WHITE, Curses::COLOR_BLACK)
MOTD = 34
Curses.init_pair(MOTD, Curses::COLOR_RED, Curses::COLOR_BLACK)

connections_info = File.open("connections.conf") { |f| YAML::load(f) }
abort("This script only supports 4 windows.") if (connections_info.length > 4)
buffers = connections_info.map { |c| []}
windows = connections_info.map.with_index { |c, i| ChatWindow.new(c, i) }

com_win = CommandWindow.new(2, 160, WIN_HEIGHT * 2, 0)
com_win.refresh
begin
    Curses.raw
    Curses.noecho
    Curses.stdscr.keypad(true)
    loop do
        com_win.setpos(0, 0)
        com_win.addstr(status.ljust(160))
        com_win.setpos(1, 0)
        com_win.addstr(">")
        key = com_win.fixed_getch()
        case key

            # Scroll up
        when '27[5~'
            windows[selected_window].scroll_up()
            status = "scroll up"

            # Scroll down
        when '27[6~'
            windows[selected_window].scroll_down()
            status = "scroll down"

            # Go to end
        when '27OF'
            windows[selected_window].go_to_end()
            status = "scroll down"

            # escape
        when '27'
            status = "escape"

            # new (ctrl-n)
        when '14'
            windows.each { |w| 3.times { |i| w.append_line(i) }}
            status = "new"

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

            # command history (up)
        when '27[A'
            status = "hist up"

            # command history (down)
        when '27[B'
            status = "hist dn"

            # Anything else
        when /[[:graph:]]/
            status = key
        end
    end
ensure
    Curses.close_screen
end




