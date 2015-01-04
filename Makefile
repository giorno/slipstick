OS=$(shell uname -s)
ifeq ($(OS),Darwin)
	INKSCAPE="/Applications/Inkscape.app/Contents/Resources/bin/inkscape"
endif

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
	$(info Checking if Inkscape is installed in $(INKSCAPE))
	@ls -la $(INKSCAPE) > /dev/null
ifeq ($(OS),Darwin)
	$(info Some SVG properties may not be supported in $(OS))
endif

# Builds printouts for Model A
model_a :
	@src/model_a.rb face > build/model_a_face.svg
	@src/model_a.rb reverse > build/model_a_reverse.svg 
	@$(INKSCAPE) -z -A build/model_a_face.pdf build/model_a_face.svg
	@$(INKSCAPE) -z -A build/model_a_reverse.pdf build/model_a_reverse.svg
	$(info Result PDF's are in directory 'build')

prerequisites : print_os check_ruby check_rasem check_inkscape

prepare: clean
	@mkdir build

