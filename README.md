slipstick
=========
This project generates printable PDF's of paper-made slide rules (it can also be used to generate various types of slide rule scales in the form of an SVG file). Printouts have to be cut out and bent along designated lines, and glued to make a particular model of slide rule.

##Prerequisites
To make it work, project requires certain applications in the environment. To make it appealing, certain fonts have to be installed.

###Basic features
This include SVG output generation for simple scales or paper models. It relies on Ruby and Ruby Gem [Rasem](https://github.com/aseldawy/rasem).

####Gentoo Linux
`emerge dev-lang/ruby dev-ruby/rubygems`

`gem install rasem`

###PDF printouts
This requires Inkscape in non-GUI mode.

####Gentoo Linux
`emerge media-gfx/inkscape`

###Fonts used for labels and scale numbering
Standard labels: [Droid Sans Mono](http://www.droidfonts.com/info/droid-sans-mono-fonts/)
Constant labels: [Droid Serif](http://www.droidfonts.com/info/droid-serif-fonts/)

Gentoo: `emerge media-fonts/droid`

##Usage

###Make paper model PDF printouts
In the project directory: `make`

PDF export will fail if prerequisite applications are not installed. Exported PDF's are put in directory `build` (created in the process).
