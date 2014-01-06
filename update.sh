#!/bin/bash

./html_to_yml.rb spoiler.html > spoiler.yml
./to_they.rb --changed spoiler.yml > reworded_cards.yml
./to_markdown.rb reworded_cards.yml > reworded_cards.md
