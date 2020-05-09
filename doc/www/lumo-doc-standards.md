<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors -->
<!-- SPDX-ArtifactOfProjectName: LumoSQL -->
<!-- SPDX-FileType: Documentation -->
<!-- SPDX-FileComment: Original by Dan Shearer, 2020 -->


Table of Contents
=================

   * [LumoSQL Documentation Standards](#lumosql-documentation-standards)
   * [Contributions to LumoSQL Documentation are Welcome](#contributions-to-lumosql-documentation-are-welcome)
   * [LumoSQL Respects Documentation for SQLite, LMDB and More](#lumosql-respects-documentation-for-sqlite-lmdb-and-more)
   * [Text Standards and Tools](#text-standards-and-tools)
   * [Diagram Standards and Tools](#diagram-standards-and-tools)
      * [LumoSQL Diagram Signature](#lumosql-diagram-signature)
      * [Using the LumoSQL Diagram Library](#using-the-lumosql-diagram-library)
      * [Adding Diagrams](#adding-diagrams)
      * [Diagram Style Guide](#diagram-style-guide)
   * [Image Standards and Tools](#image-standards-and-tools)
   * [Previewing Markdown before Pushing](#previewing-markdown-before-pushing)
   * [Copyright for LumoSQL Documentation](#copyright-for-lumosql-documentation)
   * [Metadata Header for Text Files](#metadata-header-for-text-files)
   * [Human Languages - 人类语言](#human-languages---人类语言)
   * [Creating and Maintaining Table of Contents](#creating-and-maintaining-table-of-contents)
   * [Tidying Markdown (mostly not required)](#tidying-markdown-mostly-not-required)


LumoSQL Documentation Standards
===============================

This chapter covers how LumoSQL documentation is written and maintained. 

![](./images/lumo-doc-standards-intro.jpg "Image from Wikimedia Commons, https://commons.wikimedia.org/wiki/File:Chinese_books_at_a_library.jpg")

# Contributions to LumoSQL Documentation are Welcome

The first rule of LumoSQL documentation is "Yes please, we'd be delighted to
receive patches and pull requests, in any way you want to make them". Anyone
who has gone to the trouble to write down something useful about LumoSQL is our
friend. We know there's a lot to fix.

If you want to make a quick documentation fix, then edit the Markdown and send
it to us by any means you like, especially a Github Issue or Pull Request. You
might just want to send us some improved paragraphs on their own. If this
sounds like you, stop reading now and get on with sending us text :-)

If you want to do something more serious with the documentation then you need
to read on, learning about our standards, recommended tools and processes. 

* The main website text, under the directory `doc/` .
** Text, such as this document you are reading, stored in the directory `doc/www`
** Images, such as PNG or JPEG format, stored in `doc/www/images`
** Images that are captured from videos and in the docs as thumbnails, also in `doc/www/images`

The Markdown files are standalone and complete - you can read them online just as they are.

The file `doc/www/Makefile` is an evolving tool to test these Markdown files, and soon will also
be for generating images and probably the tables of contents.

# LumoSQL Respects Documentation for SQLite, LMDB and More

LumoSQL Documentation is standalone in evey way, including formats, tools and standards.

However, LumoSQL documentation refers to and should be consulted together with the [SQLite
documentation](https://www.sqlite.org/docs.html), because with the following
exceptions, LumoSQL works (or should work) in exactly the same way as SQLite.
LumoSQL definitely not want to duplicate SQLite documentation, and regards the
excellent SQLite documentation as definitive except where indicated. 

Differences with SQLite arise:

* Where there is an extra/different storage backend to the SQLite Btree storage system
* Where there are extra parameters in the user interface (commandline, API, pragmas) for another backend
* When describing how the LumoSQL source tree works
* When LumoSQL is working as other than an embedded library
* When LumoSQL has an extra/different frontend to the SQLite SQL processor

It isn't only SQLite documentation that LumoSQL embraces. There is also [LMDB
Documentation](http://www.lmdb.tech/doc/), and more to come as LumoSQL integrates more
components. It is very important that LumoSQL not attempt to replicate these
other documentation efforts that are kept up to date along with the corresponding code.

# Text Standards and Tools

LumoSQL documentation will be written in [Github-flavoured
Markdown](https://github.github.com/gfm/) as supported by many tools including
the well-known [Pandoc](https://pandoc.org), version 2.0 or higher. LumoSQL documentation will not be
highly specific to any system. The main extension Github-flavoured Markdown
(GFM) adds is tables and code blocks, and a single switch in Pandoc can change
that dependency.

Text encoding will be [UTF-8](https://en.wikipedia.org/wiki/UTF-8) . Here is
one [expert anecdote about why UTF-8 matters](https://yihui.org/en/2018/11/biggest-regret-knitr/).

Versions of Pandoc earlier than 2.0 did not support Markdown well as an output format, and the 
Lua extension system was insufficient for LumoSQL's HTML generation needs.

One difference between Pandoc Markdown and GFM is the number of spaces for nested lists. Two
spaces are sufficient for GFM, but Pandoc requires four spaces.

# Diagram Standards and Tools

## LumoSQL Diagram Signature

The LumoSQL Diagram Signature is identical to the LumoSQL image signature. It should be 
placed on the bottom right hand corner of all diagrams created for LumoSQL, but not on
diagrams from other sources unless modified for LumoSQL.

## Using the LumoSQL Diagram Library

The file images/lumo-diagram-library.odg is a LibreOffice Draw document containing all 
the elements likely needed for LumoSQL technical diagrams. If you find that you need to
add a new element when making a diagram, you should also add it to this document.

The lumo-signature file is to be added to the base of all LumoSQL diagrams and images.
It contains the logo and copyright string.

All other diagrams in images/ are PNG format final diagrams and SVG format process
diagrams kept for ease of editing, as exported by LibreOffice, inkscape and others.

## Adding Diagrams

The current process for making diagrams is as follows.

1. Make in LibreOffice Draw.
1.1 Reset corners of box elements to their proper radii (LibreOffice modifies this when scaling boxes).
  1.2. Export as SVG.
2. Convert to png and add signature.
  4.1 Trim borders and output: `$ convert -density 200 -trim MyLbreOfficeOutput.svg MyNewDiagram.png`
  4.2 Re-border with space for the logo(adjust border as required if the signature doesn't fit): `$ convert MyNewDiagram.png -bordercolor white -border 40x40 -gravity south -splice 0x80 MyNewDiagram.png`
  4.3 Add logo and copyright information: `$ composite -density 200 -gravity SouthEast lumo-signature.svg MyNewDiagram.png MyNewDiagram.png`

## Diagram Style Guide

Colour palette: Libreoffice 'standard'.
Fonts: *Source (Han) Sans Medium* or *Noto Sans Medium* due to their on-screen clarity and good language support (both are 100% compatible)
Corner radii: OS and large container boxes: 0.4, small box elements: 0.25

# Image Standards and Tools

Images for LumoSQL documentation will be stored in /images/ and the
filenames should start with `lumo-` . PNG should be the default image format, 
followed by JPG. 

Include attribution in the alt-text tag. All images should have attribution,
even if the LumoSQL project provided them.  The caption should be left out if
the image is self-evident and the alt-text also explains what the image is, 
This example is approximately from the top of this chapter:

```
![Optional caption, eg "Chart of Badgers vs Profit"](./images/lumo-doc-standards-intro.jpg "Image from Wikimedia Commons, https://commons.wikimedia.org/wiki/File:Chinese_books_at_a_library.jpg")
```

# Previewing Markdown before Pushing

It's best to check syntax before pushing changes, which means rendering
Markdown into HTML that is hopefully close to what Github produces. Here are three ways of doing that:

* The Makefile and support files in bin/ uses Pandoc to render the GFM to HTML in /tmp . Just type 'make 
* The excellent [Editor.md](https://github.com/pandao/editor.md) does a great job of rendering,
as can be seen at [The Online Installation](https://pandao.github.io/editor.md/en.html) . You can paste GFM into it and see it rendered, WYSIWYG-style. You can download the HTML for
Editor.md and run it locally. (Editor.md is also an editor, and it adds its own features, but you don't need to use it for that.)
* You can use the Preview button on the Github user interface, for people whose workflow that suits.

# Copyright for LumoSQL Documentation

LumoSQL documentation is original and copyrighted under the 
[Creative Commons By-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode), 
except where indicated. Mostly it's better to link to the original, but if you
need to cite paragraphs of someone else's documentation then attribute, and if
more, check the license on the original.

The Creative Commons copyright applies to all LumoSQL documentation media.

Some documentation or media brings conditions of use with it, especially
attribution, and this must be respected.

# Metadata Header for Text Files

The first lines of all LumoSQL documentation files should always be something like this:

```
   <!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
   <!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors -->
   <!-- SPDX-ArtifactOfProjectName: LumoSQL -->
   <!-- SPDX-FileType: Documentation -->
   <!-- SPDX-FileComment: Original by Dan Shearer, 2020 -->
```

# Human Languages - 人类语言

English is currently the main documentation language. Others are welcome, and
not just as translations. For example, embedded SQL is particularly important
in China and we welcome original content. To make it feel welcoming, we have tried
to make all the illustrative images in LumoSQL inclusive of chinese language.

# Creating and Maintaining Table of Contents

LumoSQL had to make a decision about creating navigable ToC indexes. We would rather not 
write our own tools or scripts. At the moment the following is what we have.

The problem we have is summarised in a [well-known Github bug report](https://github.com/isaacs/github/issues/215):

> When I see a manually generated table of contents, it makes me sad.
> When I see a huge README that is impossible to navigate without it, it makes me even sadder.
> LaTeX has it. Gollum has it. Pandoc has it. So why not Github Format Markdown?

**LumoSQL Decision as of March 2020**: ToC Markdown must appear in the raw markdown. That means a TOC
needs to be created and then inserted into the original source markdown file
rather than automatically generated as part of an online rendering process or offline pipeline.

**Non-markdown metadata won't work:** With Pandoc, when writing, say, a report
in Markdown, a tiny bit of metadata at the top of the file allows us to say
`\tableofcontents`  and `/usr/bin/pandoc` will then produce a beautiful PDF,
and also other formats such as HTML.  However, LumoSQL documentation needs to
be processed by renderers that are a lot less sophisticated than Pandoc,
including the Github markup processor. So we can't rely on metadata.

**Pandoc's Markdown output is improving but not yet good enough:** Pandoc can 
read Markdown and output Markdown, including a ToC.  A command such as 

```pandoc --standalone -f gfm -t gfm --toc -o lumo-output.md -i lumo-input.md```

is supposed to work and probably does, we just haven't seen it yet. Pandoc's Markdown
output used to be poor, but since version 2.0 is has improved a lot. Pandoc --toc is
hopefully the eventual answer, although as of 2.9 it doesn't seem to work at all, despite 
the documentation claiming it does.

**We are left with ad-hoc processing solutions for now:**

* Use the Github API: The most practical solution we have for now is the
[github-markdown-toc](https://github.com/ekalinin/github-markdown-toc) bash
script:

```
    $ https://raw.githubusercontent.com/ekalinin/github-markdown-toc/master/gh-md-toc
    $ ./gh-md-toc some-lumosql-document.md > /tmp/toc.md
```

Then insert the file /tmp/toc.md into the document using your editor. It's not
a pretty operation but given all the other advantages of Markdown it seems a
small price to pay. This script can now be found in ```www/bin/gh-md-toc``` .
It uses the Github API and therefore produces canonical results, so that means
it needs internet access. After more testing, perhaps we can trust the
`--insert` option and then include gd-md-toc in the documentation Makefile.

The way API works is made clear in the comments:

	# Converts local md file into html by GitHub
	# $ curl -X POST --data '{"text": "Hello world github/linguist#1 **cool**, and #1!"}' https://api.github.com/markdown
	# <p>Hello world github/linguist#1 <strong>cool</strong>, and #1!</p>'"

gh-md-toc will insert a TOC between these markers:

```
    <!--ts-->
    <!--te-->
```

meaning TOC could be handled in the Makefile, but that requires further thought.

* There are also options for doing Markdown TOC in editors such as vim, for example [vim-markdown-toc](https://github.com/mzlogin/vim-markdown-toc)

* Editor.md, referred to in the "Previewing Markdown Before Pushing" section
above, will generate a table of contents where it sees the token `[TOC]` and a
dropdown index TOC menu where it sees `[TOCM`. However since the output is HTML
not markdown it is not so useful to LumoSQL (but it is very beautiful.)

# Tidying Markdown (mostly not required)

Tidying is about automatically adjusting the whitespace, pagebreaks and general formatting 
to be neat and consistent. But maybe you don't even need to, just write tidy 
text in the first place. 

If you want to clean up someone else's Markdown, then stop and ask first.
Automated cleanups and prettiers change hundreds of lines in a file without any
effect on the output, and that makes a diff impossible to review, effectively
rebasing it and destroying the history.

The documentation Makefile is not going to include any Markdown tidying because
of the potential for making things worse. As of version 2.0 Pandoc works better
for cleaning up markdown but isn't perfect. Parameters to experiment with include:

```
  -t gfm            (triggers a few defaults, including headers in ATX style)
  --wrap=preserve   (mostly limits changes to making headings ATX style)
  --columns=85      (stops most links breaking in editors doing syntax highlighting)
```
  
