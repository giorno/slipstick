.PHONY: fonts tex

OS=$(shell uname -s)
ifeq ($(OS),Darwin)
	INKSCAPE="/Applications/Inkscape.app/Contents/Resources/bin/inkscape"
else
	INKSCAPE=$(shell which inkscape 2> /dev/null)
endif

all : prerequisites prepare fonts tex model_a

clean :
	@rm -rf build

print_os :
	$(info Detected operating system: $(OS))

check_ruby :
	$(info Checking if Ruby is installed)
	@which ruby > /dev/null

check_rasem :
	$(info Checking if Ruby Gem Rasem is installed)
	@gem list | grep rasem > /dev/null

check_gs :
	$(info Checking if Ghostscript is installed)
	@which gs > /dev/null

# TODO this may be an optional tool
check_xmllint :
	$(info Checking if xmllint is installed)
	@which xmllint > /dev/null

check_inkscape :
ifeq ($(OS),Darwin)
	$(info Checking if Inkscape is installed in $(INKSCAPE))
	@ls -la $(INKSCAPE) > /dev/null
	$(info Some SVG properties may not be supported in $(OS))
else
	$(info Checking if Inkscape is installed)
ifeq ($(INKSCAPE),)
	$(error Inkscape binary not found)
endif
endif

fonts :
ifneq ($(OS),Darwin)
	@$(MAKE) -C fonts install
	@$(MAKE) -C tex fonts
else
	$(warning Fonts are not generated on Mac OS X)
endif

tex :
	@$(MAKE) -C tex all


# Builds printouts for Model A
model_a :
	$(info Generating Model A)
	@src/model_a.rb en stock face | xmllint --format - > build/model_a_stock_face.svg
	@src/model_a.rb en stock reverse | xmllint --format - > build/model_a_stock_reverse.svg 
	@src/model_a.rb en slide face | xmllint --format - > build/model_a_slide_face.svg
	@src/model_a.rb en slide reverse | xmllint --format - > build/model_a_slide_reverse.svg 
	@src/model_a.rb en transp face | xmllint --format - > build/model_a_transp_face.svg
	@src/model_a.rb en transp reverse | xmllint --format - > build/model_a_transp_reverse.svg 
	@$(INKSCAPE) -z -A $(shell pwd)/build/model_a_stock_face.pdf $(shell pwd)/build/model_a_stock_face.svg
	@$(INKSCAPE) -z -A $(shell pwd)/build/model_a_stock_reverse.pdf $(shell pwd)/build/model_a_stock_reverse.svg
	@$(INKSCAPE) -z -A $(shell pwd)/build/model_a_slide_face.pdf $(shell pwd)/build/model_a_slide_face.svg
	@$(INKSCAPE) -z -A $(shell pwd)/build/model_a_slide_reverse.pdf $(shell pwd)/build/model_a_slide_reverse.svg
	@$(INKSCAPE) -z -A $(shell pwd)/build/model_a_transp_face.pdf $(shell pwd)/build/model_a_transp_face.svg
	@$(INKSCAPE) -z -A $(shell pwd)/build/model_a_transp_reverse.pdf $(shell pwd)/build/model_a_transp_reverse.svg
	@gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile=build/model_a.pdf build/model_a_stock_face.pdf build/model_a_stock_reverse.pdf build/model_a_slide_face.pdf build/model_a_slide_reverse.pdf build/model_a_transp_face.pdf build/model_a_transp_reverse.pdf build/making_en.pdf build/using_en.pdf
	@echo "Result PDF's are in directory 'build'"

model_a_debug :
	@echo "Generating debug (all layers) SVG's of Model A"
	@src/model_a.rb en stock both | xmllint --format - > build/model_a_stock_both.svg
	@src/model_a.rb en slide both | xmllint --format - > build/model_a_slide_both.svg
	@src/model_a.rb en transp both | xmllint --format - > build/model_a_transp_both.svg
	@echo "Result SVG's are in directory 'build', suffixed '_both.svg'"
	@echo "Use 'ls -la build/*_both.svg' to list them"

prerequisites : print_os check_ruby check_rasem check_xmllint check_inkscape check_gs

prepare:
	@cp artwork/logo.svg build/logo.svg
	@mkdir -p build

