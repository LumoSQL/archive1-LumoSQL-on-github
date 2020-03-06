<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors -->
<!-- SPDX-FileType: Documentation -->

LumoSQL Documentation Standards
===============================

This chapter covers how LumoSQL documentation should be written and maintained. 

![](./images/lumo-doc-standards-intro.jpg "Image from Wikimedia Commons, https://commons.wikimedia.org/wiki/File:Chinese_books_at_a_library.jpg")

Table of Contents
=================

   * [Table of Contents](#table-of-contents)
   * [Contributions to LumoSQL Documentation are Welcome](#contributions-to-lumosql-documentation-are-welcome)
   * [LumoSQL Documentation](#lumosql-documentation)
   * [Standards for Text Markup](#standards-for-text-markup)
   * [Previewing Markdown before Pushing](#previewing-markdown-before-pushing)
   * [Copyright for LumoSQL Documentation](#copyright-for-lumosql-documentation)
   * [Metadata Header for Text Files](#metadata-header-for-text-files)
   * [Images](#images)
   * [Human Languages - 人类语言](#human-languages---人类语言)
   * [Creating and Maintaining Table of Contents](#creating-and-maintaining-table-of-contents)
   * [Tidying Markdown (if really required)](#tidying-markdown-if-really-required)


# Contributions to LumoSQL Documentation are Welcome

The first rule of LumoSQL documentation is "Yes please, we'd be delighted to
receive patches and pull requests, however you want to make them". Anyone who
has gone to the trouble to write down how they solve a problem with LumoSQL is
our friend. We know there's a lot to fix.

The rest of this document describes our standards, recommended tools and processes.

# LumoSQL Documentation

LumoSQL documentation sits alongside the [SQLite documentation](https://www.sqlite.org/docs.html), because with the
following exceptions, LumoSQL works (or should work) in exactly the same way as
SQLite. Differences with SQLite arise:

* Where there is an extra/different storage backend to the SQLite Btree storage system
* Where there are extra parameters in the user interface (commandline, API, pragmas) for another backend
* When describing how the LumoSQL source tree works
* When LumoSQL is working as other than an embedded library
* When LumoSQL has an extra/different frontend to the SQLite SQL processor

LumoSQL documentation media includes:

* The main website text, under the directory `doc/www`
** Text, such as this document, stored in the directory `doc/www`
** Images, such as PNG or JPEG format, stored in `doc/www/images`
** Images that are captured from videos and in the docs as thumbnails, also in `doc/www/images`

# Standards for Text Markup

LumoSQL documentation will be written in [Github-flavoured
Markdown](https://github.github.com/gfm/) as supported by many tools including
the well-known [Pandoc](https://pandoc.org). LumoSQL documentation will not be
specific to any system, certainly not Github. The main extension
Github-flavoured Markdown (GFM) adds is tables and code blocks.

Text encoding will be [UTF-8](https://en.wikipedia.org/wiki/UTF-8) . Here is
one [expert anecdote about why UTF-8 matters](https://yihui.org/en/2018/11/biggest-regret-knitr/).

While Pandoc is generally excellent at handling Markdown input and allows
LumoSQL documentation to be presented in many other formats such as PDF, Pandoc
cannot be a default documentation tool for LumoSQL because (strangely) Markdown
itself is not well-supported by Pandoc as an output format as of February 2020.

# Previewing Markdown before Pushing

It's best to check syntax before pushing changes, which means rendering
Markdown into HTML. Here are three ways of doing that:

* You can do this with `pandoc -t html input.md -o output.html and then use your browser to look at the file output.html
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

The first lines of all LumoSQL documentation files should always be:

```
<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- SPDX-FileCopyrightText: 2020 The LumoSQL Authors -->
<!-- SPDX-FileType: Documentation -->
```

# Images

Images for LumoSQL documentation will be stored in doc/www/images/ and the
filenames should start with `lumo-` . PNG should be the default image format, 
followed by JPG. 

Include attribution in the alt-text tag. All images should have attribution,
even if the LumoSQL project provided them.  The caption should be left out if
the image is self-evident and the alt-text also explains what the image is, 
This example is approximately from the top of this chapter:

```
![Optional caption, eg "Chart of Badgers vs Profit"](./images/lumo-doc-standards-intro.jpg "Image from Wikimedia Commons, https://commons.wikimedia.org/wiki/File:Chinese_books_at_a_library.jpg")
```

# Human Languages - 人类语言

English is currently the main documentation language. Others are welcome, and
not just as translations. For example, embedded SQL is particularly important
in China and we welcome original content. As a welcoming gesture, we have tried
to make illustrative images inclusive of chinese language.

# Creating and Maintaining Table of Contents

To quote a [well-known Github bug report](https://github.com/isaacs/github/issues/215):

> When I see a manually generated table of contents, it makes me sad.
> When I see a huge README that is impossible to navigate without it, it makes me even sadder.
> LaTeX has it. Gollum has it. Pandoc has it. So why not Github Format Markdown?

LumoSQL had to make a decision about creating navigable indexes. 

With Pandoc, when writing, say, a report in Markdown, a tiny bit of metadata at
the top of the file allows us to say `\tableofcontents`  and `/usr/bin/pandoc`
will then produce a beautiful PDF, and also other formats such as HTML. 

LumoSQL documentation needs to be processed by renderers that are a lot less
sophisticated than Pandoc, including Github itself.  That means that any table
of contents has to appear in the raw markdown, and _that_ means that a TOC
needs to be created and then inserted into the raw markdown rather than
automatically generated as part of the rendering process.

So what software will parse Markdown and produce a TOC? Ideally that would be Pandoc,
but sadly Pandoc cannot reliably produce Markdown. A command such as
`pandoc -t markdown_github --toc input.md -o output.md` just doesn't work, or any of the 
variations.

One reasonable solution is the [github-markdown-toc](https://github.com/ekalinin/github-markdown-toc). You can get the script at wget https://raw.githubusercontent.com/ekalinin/github-markdown-toc/master/gh-md-toc and use it like this:

`gh-md-toc some-lumosql-document.md > /tmp/toc.md`

and then insert the file /tmp/toc.md into the document using your editor. It's
not a pretty operation but given all the other advantages of Markdown it seems
a small price to pay. 

There are also options for doing in editors such as vim. 

Editor.md, referred to in the "Previewing Markdown Before Pushing" section above, will generate a table of contents where it sees the token `[TOC]` and a dropdown index TOC menu where it sees `[TOCM`. However since the output is HTML not markdown it is not as helpful as it may seem (but it is very beautiful.)

# Tidying Markdown (if really required)

Tidying is about automatically adjusting the whitespace, pagebreaks and general formatting 
to be neat and consistent. But maybe you don't even need to?  

If you want to clean up someone else's Markdown, then stop and ask first.
Automated cleanups and prettiers change hundreds of lines in a file without any
effect on the output, and that makes a diff impossible to review, effectively
rebasing it and destroying the history.

If it's your own markdown, it's much better to run prettier before the first
commit of a file and then again before subsequent commits - or just write clean
Markdown and you can expect others to respect that.

It would be ideal if we could use Pandoc to clean up markdown, but it just
doesn't work.  There are several pretty printing pacakges to choose from. 
One that may work is [Prettier](https://prettier.io) , although that requires 
familiarity with Node package installation and configuration. (LumoSQL uses 
Node for the benchmarking code, so arguably you will have NodeJS installed anyway.)


