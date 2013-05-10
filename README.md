IRC-Client
==========

A console-based IRC client that supports multiple connections and split windows

## Usage

Provide a YAML file with up to four connections (see connections.yml for an example), and run

    ruby run.rb connections.yml

## Gems required

[Cinch](http://rubygems.org/gems/cinch)

## Controls

- up arrow, down arrow - Scroll up/down
- page up, page down - Scroll a whole page up/down
- ctrl-up, ctrl-down - next/previous highlighted window

## Commands

- /save - saves the channel buffers to timestamped files
