#!/usr/bin/ruby

require 'yaml'
require 'optparse'
require 'active_support/inflector'

options = {}

@replacements = {
  ' his or her '  => ' their ',
  ' he or she '   => ' they ',
  ' His or her '  => ' Their ',
  ' He or she '   => ' They '
}

def rephraseCard(card)
  changed = false
  rules = card['rules']
  return card, false if rules.nil?
  @replacements.each_pair do |search, replace|
    localchange = rules.gsub! search, replace
    changed = changed || ! localchange.nil?
  end


  # Singularize the words after each 'they'
  matches = /(they\s+[-'A-Za-z]+)/i.match(rules)
  unless matches.nil?
    matches.captures.each do |capture|
      words = capture.split " "
      words[-1] = words[-1].singularize
      rules.sub! capture, words.join(' ')
    end
  end

  card['rules'] = rules
  return card, changed
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

changedcards = []

cards.each do |card|
  card, changed = rephraseCard(card)
  if changed or !options[:changed]
    changedcards.push(card)
  end
end

puts YAML.dump(changedcards)
