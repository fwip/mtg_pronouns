#!/usr/bin/ruby
require 'yaml'
require 'nokogiri'

def text_to_icon(text, convert_all=false)
  return '' if text.nil?
  regex = convert_all ? /([0-9]+|[wubrgspxyzq]|\(.*?\))/i : /({.*?})/
  text.gsub!(regex) do |c|
    c.downcase!
    c.gsub!(/[(){}\/]/, '')
    "<img src='img/#{c}.png'>"
  end
  text
end

def add_rules(doc, card)
  rules = card['rules'].split("\n")
  doc.div.rules {
    rules.each do |rule|
      rule.gsub!('—', '-')
      #rule = rules_to_icons(rule)
      rule = text_to_icon(rule)
      parens = /(.*)(\(.*?\))/.match(rule)
      if parens.nil?
        doc.div.rule { doc << rule }
      else
        doc.div.rule {
          doc << parens.captures.first
          doc.span.parens { doc << parens.captures.last }
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
                  doc << text_to_icon(card['cost'], true)
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
