#!/usr/bin/ruby
require 'yaml'
require 'nokogiri'

def to_icon(doc, char)
  if ( /[UGRBW]/ =~ char )
    doc.img src: "#{char}.png"
  else
    doc.text char
  end
end


def to_icons(doc, text)
  matches = /{([T0-9WUGBR])}/.match(text)
  if matches.nil?
    doc.text text
  else
    matches.each do |char|
      to_icon(doc, char)
    end
  end
end

def add_rules(doc, card)
  rules = card['rules'].split("\n")
  doc.div.rules {
    rules.each do |rule|
      parens = /(.*)(\(.*\))/.match(rule)
      if parens.nil?
        doc.div.rule { doc.text rule }
      else
        doc.div.rule {
          doc.text parens.captures.first
          doc.span.parens { doc.text parens.captures.last }
        }
      end
    end
  }

end

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
            doc.div.card(class: get_color(card)) {
              doc.div.title {
                doc.text card['name']
                doc.div.cost {
                  unless card['cost'].nil?
                    card['cost'].split('').each do |c|
                      to_icon doc, c
                    end
                  end
                  #doc.text card['cost']
                }
              }
              doc.div.type {
                doc.text card['type']
              }

              add_rules(doc, card)

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
