.PHONY: fonts

OS=$(shell uname -s)
ifeq ($(OS),Darwin)
	INKSCAPE="/Applications/Inkscape.app/Contents/Resources/bin/inkscape"
else
	INKSCAPE=$(shell which inkscape 2> /dev/null)
endif

all : prerequisites prepare fonts model_a

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
	@$(MAKE) -C fonts install

# Builds printouts for Model A
model_a :
	$(info Generating Model A)
	@src/model_a.rb stock face | xmllint --format - > build/model_a_stock_face.svg
	@src/model_a.rb stock reverse | xmllint --format - > build/model_a_stock_reverse.svg 
	@src/model_a.rb slide face | xmllint --format - > build/model_a_slide_face.svg
	@src/model_a.rb slide reverse | xmllint --format - > build/model_a_slide_reverse.svg 
	@$(INKSCAPE) -z -A build/model_a_stock_face.pdf build/model_a_stock_face.svg
	@$(INKSCAPE) -z -A build/model_a_stock_reverse.pdf build/model_a_stock_reverse.svg
	@$(INKSCAPE) -z -A build/model_a_slide_face.pdf build/model_a_slide_face.svg
	@$(INKSCAPE) -z -A build/model_a_slide_reverse.pdf build/model_a_slide_reverse.svg
	@gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=build/model_a.pdf build/model_a_stock_face.pdf build/model_a_stock_reverse.pdf build/model_a_slide_face.pdf build/model_a_slide_reverse.pdf
	@echo "Result PDF's are in directory 'build'"

prerequisites : print_os check_ruby check_rasem check_xmllint check_inkscape check_gs

prepare:
	@mkdir -p build

