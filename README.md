# Slipstick - A Paper Made Slide Rule
This project generates printable PDF's of paper-made slide rules (it can also be used to generate various types of slide rule scales in the form of an SVG file). Printouts have to be cut out and bent along designated lines, and glued to make a particular model of slide rule.

## Dependencies
A number of other applications and packages are expected to be present in the system to run the build system. Their absence is detected and breaks the build.

 * Ruby
 * Ruby Gems: [Rasem](https://github.com/aseldawy/rasem), [RQRCoder](https://github.com/whomwah/rqrcode)
 * Wget
 * FontForge
 * Inkscape
 * Xelatex
 * TexLive packages: texlive-latex-extra
 * Ghostscript

### Install dependencies from MacPorts on macOS

### Install dependencies on Gentoo Linux

```
emerge dev-lang/ruby dev-ruby/rubygems
gem install rasem
gem install rqrcode
emerge media-gfx/inkscape
```

## Build
In the project directory:
```
make
```
