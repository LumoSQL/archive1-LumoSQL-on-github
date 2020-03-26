# LumoSQL Documentation Makefile
#
# This Makefile will do a test rendering of Github flavoured Markdown to HTML`
#
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2019 The LumoSQL Authors
#
#
# In order to use this Makefile, you need Pandoc version 2.0 or higher, https://pandoc.org
#
# This Makefile does not do many safety checks yet

# Directory containing source (Markdown) files
source := $(CURDIR)

# Temporary target directory for HTML
output := /tmp/lumo-www


# All markdown files in src/ are considered sources
sources := $(wildcard $(source)/*.md)

# Convert the list of source files (Markdown files in directory src/)
# into a list of output files (HTML files in temporary directory)
objects := $(patsubst %.md,%.html,$(subst $(source),$(output),$(sources)))

all: preptmp $(objects)

# Recipe for getting clean temporary directory for local HTML rendering of GHF Markdown
preptmp: 
	if test -d $(output); then rm -rf $(output); fi
	echo $(output)
	mkdir $(output)
	cp -a images $(output)


# Recipe for converting a Markdown file into PDF using Pandoc
$(output)/%.html: $(source)/%.md
	pandoc \
		--lua-filter=bin/md-links-html.lua \
		-f gfm  $< \
		-o $@

.PHONY : clean

clean:
	rm -f $(output)/*.html
