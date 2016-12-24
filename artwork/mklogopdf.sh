#!/bin/bash

# Converts the SVG file into LATEX PDF for use in the TEX files.

INKSCAPE="inkscape"
if [ "Darwin" = `uname -s` ]; then
    INKSCAPE="/Applications/Inkscape.app/Contents/Resources/bin/inkscape"
fi

$INKSCAPE -D -z --file=$PWD/logo.svg --export-pdf=$PWD/logo.pdf --export-latex

