#!/usr/bin/ruby

require 'nokogiri'
require 'yaml'

htmlfile = ARGV.first

doc = Nokogiri::HTML(open(htmlfile))

card = nil
cards = []
fieldindex = 0
fields = [nil, 'name', nil, 'cost', nil, 'type', nil, 'p/t', nil, 'rules', nil, 'set']

doc.xpath('//table/tr/td').each do |td|

  text = td.content.strip
  if (text == 'Name')
    fieldindex = 0
    cards.push(card) unless card.nil?
    card = {}
  end
  type = fields[fieldindex]
  fieldindex += 1
  unless type.nil? or text.empty?
    card[type] = text
  end
end

puts cards.to_yaml
