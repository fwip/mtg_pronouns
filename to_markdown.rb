#!/usr/bin/ruby

require 'yaml'

def card_to_s(card)
    text =  "#{card['name']} #{card['cost']}\n"
    text += "---------------\n\n"
    text += "**#{card['type']}**\n\n"
    text += card['rules'].gsub "\n", "\n\n"
    text += "\n\n"
    unless card['p/t'].nil?
      text += "**#{card['p/t']}**\n\n"
    end
    return text
end

cardfile = ARGV.first

cards = YAML.load_file cardfile

cards.each do |card|
  puts card_to_s card
end
