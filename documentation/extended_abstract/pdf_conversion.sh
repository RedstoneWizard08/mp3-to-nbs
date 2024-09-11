#!/bin/sh
# https://learnbyexample.github.io/customizing-pandoc/
pandoc documentation.md \
-f gfm \
-H header.tex \
--include-before-body title.tex \
-V linkcolor:blue \
-V geometry:margin=2cm \
--toc \
--pdf-engine=xelatex \
-o documentation.pdf \
#--verbose

#-V fontsize=12pt \

pandoc documentation_en.md \
-f gfm \
-H header_en.tex \
--include-before-body title_en.tex \
-V linkcolor:blue \
-V geometry:margin=2cm \
--toc \
--pdf-engine=xelatex \
-o documentation_en.pdf \
#--verbose

#-V fontsize=12pt \

# Szükséges:
# sudo apt install librsvg2-bin texlive-xetex
