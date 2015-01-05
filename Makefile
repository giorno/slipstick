OS=$(shell uname -s)
INKSCAPE=$(shell which inkscape 2> /dev/null)

all : prerequisites prepare model_a

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

check_inkscape :
ifeq ($(OS),Darwin)
	INKSCAPE="/Applications/Inkscape.app/Contents/Resources/bin/inkscape"
	$(info Checking if Inkscape is installed in $(INKSCAPE))
	@ls -la $(INKSCAPE) > /dev/null
	$(info Some SVG properties may not be supported in $(OS))
else
	$(info Checking if Inkscape is installed)
ifeq ($(INKSCAPE),)
	$(error Inkscape binary not found)
endif
endif

# Builds printouts for Model A
model_a :
	@src/model_a.rb face > build/model_a_face.svg
	@src/model_a.rb reverse > build/model_a_reverse.svg 
	@$(INKSCAPE) -z -A build/model_a_face.pdf build/model_a_face.svg
	@$(INKSCAPE) -z -A build/model_a_reverse.pdf build/model_a_reverse.svg
	@echo "Result PDF's are in directory 'build'"

prerequisites : print_os check_ruby check_rasem check_inkscape

prepare: clean
	@mkdir build

