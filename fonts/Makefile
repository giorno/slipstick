OS=$(shell uname -s)

USERNAME=$(shell whoami)

ifeq ($(OS),Darwin)
	FONTFORGE="/Applications/Inkscape.app/Contents/Resources/bin/inkscape"
else
	FONTFORGE=$(shell which fontforge 2> /dev/null)
endif

all : prerequisites prepare fonts

clean :
	@rm -rf ../build/*.ttf

print_os :
	$(info Detected operating system: $(OS))

check_ff :
ifeq ($(OS),Darwin)
	$(info Checking if FontForge is installed in $(FONTFORGE))
	@ls -la $(FONTFORGE) > /dev/null
else
	$(info Checking if FontForge is installed)
ifeq ($(FONTFORGE),)
	$(error FontForge binary not found)
endif
endif

# Builds printouts for Model A
fonts :
	@$(FONTFORGE) -lang=ff -c 'Open("SlipstickSansMono-Regular.sfd"); Generate("../build/SlipstickSansMono-Regular.ttf");' 2> /dev/null
	@$(FONTFORGE) -lang=ff -c 'Open("SlipstickSansMono-Bold.sfd"); Generate("../build/SlipstickSansMono-Bold.ttf");' 2> /dev/null
	@$(FONTFORGE) -lang=ff -c 'Open("SlipstickSansMono-Italic.sfd"); Generate("../build/SlipstickSansMono-Italic.ttf");' 2> /dev/null

install : fonts
	$(info Installing fonts for user $(USERNAME))
	@cp ../build/*.ttf ~/.fonts
	@fc-cache -f -v > /dev/null

prerequisites : print_os check_ff

prepare: clean
	@mkdir -p ../build

