#!/usr/bin/ruby
require 'yaml'
require 'nokogiri'

def get_color(card)
  return 'land' if card['cost'].nil?
  costcolors = card['cost'].gsub(/[^WUGBR]/, '')
  colors = costcolors.split('').uniq

  return 'nocolor' if colors.empty?

  if (colors.size > 1)
    return 'gold'
  end

  return colors.first

end

def emit_html(cards)
  Nokogiri::HTML::Builder.new do |doc|
    doc.html {
      doc.head {
        doc.link rel: 'stylesheet', href: 'style.css', type: 'text/css', media: 'screen'
      }
      doc.body {
        doc.div.container {
          cards.each do |card|
            rules = card['rules'].split("\n")
            doc.div.card(class: get_color(card)) {
              doc.div.title {
                doc.text card['name']
                doc.div.cost {
                  doc.text card['cost']
                }
              }
              doc.div.type {
                doc.text card['type']
              }
              doc.div.rules {
                rules.each do |rule|
                  doc.div.rule { doc.text rule }
                end
              }
              doc.div.pt {
                doc.text card['p/t']
              }
            }
          end
        }
      }
    }
  end.to_html
end


cardfile = ARGV.first
cards = YAML.load_file cardfile

puts emit_html(cards)
