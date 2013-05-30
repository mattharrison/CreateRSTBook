#!/bin/bash

DIR=$1

if [ ! -d "$DIR" ]; then
    mkdir $DIR
    mkdir $DIR/assets
    mkdir $DIR/rst
    mkdir $DIR/img
    mkdir $DIR/build
    mkdir $DIR/meta

    cat > $DIR/meta/amzn_notes.rst <<EOF
book name:
title:
volume:
edition #:
publisher:
description:
contributors:
language:
pub date:
isbn:
public domain:
categories:
search keywords:
drm:
territories:
royalty:
price:
in-price:
uk-price:
de-price:
fr-price:
es-price:
it-price:
jp-price:
br-price:
ca-price:
lending:
EOF


    cat > $DIR/requirements.txt <<EOF
docutils
Genshi
rst2epub2
https://launchpad.net/rubber/trunk/1.1/+download/rubber-20100306.tar.gz
#rst2nitrile
EOF

    cat > $DIR/Makefile <<EOF
PIP := env/bin/pip
NOSE := env/bin/nosetests
PY := env/bin/python
BIN := env/bin/
SHELL = /bin/bash
BOOKFILENAME = book

# -------- Environment --------
# env is a folder so no phony is necessary
env:
	virtualenv env

.PHONY: deps
deps: env packages/.done \$DU $DU\$DU


\$(DU):
	# see http://tartley.com/?p=1423&cpage=1
	# --upgrade needed to force local (if there's a system install)
	\$(PIP) install --upgrade --no-index --find-links=file://\${PWD\}/packages -r requirements.txt

packages/.done:
	mkdir packages; \
	\$(PIP) install --download packages -r requirements.txt;\
	touch packages/.done

rstbook: deps
	\$(BIN)rst2epub.py -r 3 --traceback book.rst build/\${BOOKFILENAME}.epub; pushd build; kindlegen-2.7 \${BOOKFILENAME}.epub -o \${BOOKFILENAME}.mobi; popd

amazon_description: deps
	\$(BIN)rst2html meta/amzn_description.rst build/amzn_description.txt ;\
	python -c 'import cgi, sys; print cgi.escape(sys.stdin.read())' < build/amzn_description.txt

latexbook: deps
	\$(BIN)rst2nitrile.py -r 3 --traceback book.rst build/\${BOOKFILENAME}.tex; pushd build; rubber -d pdf \$\{BOOKFILENAME}.tex; popd

EOF

    cat > $DIR/rst/book.rst <<EOF

==============================================================
 \${TITLE}
==============================================================

.. include:: <isonum.txt>
.. include:: <isopub.txt>

.. |date| date::

.. image:: img/funccover.png
  :class: cover

:creator: \${AUTHOR}
:title:  \${TITLE}
:language: en
:publisher: \${PUB}
:description: Learn Intermediate Python Programming quickly, and correctly |date|
:subject: Python Programming Language
:rights: Copyright |copy| \${YEAR} — \${AUTHOR} — All rights reserved


.. http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html#id59 for curly quotes, em dash, etc


.. titlepage

.. raw:: html

  <div class="title">
    <hr/>
    <h1 class="center">\${TITLE}</h1>
    <h2 class="center">\${SUBTITLE}</h2>
    <h1 class="center">\${AUTHOR}</h1>
    <hr/>
    <h2 class="center">\${PUB}</h2>
  </div>


.. newpage:

.. raw:: html

  <div class="copyright-top">
  <p class="no-indent">\${AUTHOR}</p>
  <p class="no-indent">Copyright &copy; \${YEAR}</p>
  </div>
  <p class="no-indent smaller">While every precaution has been taken in the preparation of this
  book, the publisher and author assumes no responsibility for errors
  or omissions, or for damages resulting from the use of the
  information contained herein.</p>

|date|


.. toc:show

Chapters Go Here
==================

Content
Test
EOF

fi
