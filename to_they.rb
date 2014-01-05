#!/usr/bin/ruby

require 'yaml'
require 'optparse'

options = {}

@replacements = {
  ' his or her '  => ' their ',
  ' he or she '   => ' they ',
  ' that player ' => ' they ',
  ' His or her '  => ' Their ',
  ' He or she '   => ' They ',
  ' That player ' => ' They '
}

def rephraseCard(card)
  changed = false
  rules = card['rules']
  return card, false if rules.nil?
  @replacements.each_pair do |search, replace|
    localchange = rules.gsub! search, replace
    changed = changed || ! localchange.nil?
  end
  card['rules'] = rules
  return card, changed
end

def card_to_s(card)
    text =  "#{card['name']} #{card['cost']}\n"
    text += "---------------\n\n"
    text += card['rules'].gsub "\n", "\n\n"
    text += "\n\n"
    return text
end

OptionParser.new do |opts|
  opts.banner = "Usage: to_they.rb <file> [options]"

  opts.on("-c", "--changed", "Only print changed") do |c|
    options[:changed] = c
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
end.parse!

cardfile = ARGV.first
cards = YAML.load_file cardfile

cards.each do |card|
  card, changed = rephraseCard card
  if !options[:changed] or changed
    puts card_to_s card
  end
end
