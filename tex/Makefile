
OS=$(shell uname -s)
XELATEX=$(shell which xelatex 2> /dev/null)

all: prepare check_xelatex check_wget fonts tex

clean:
	@rm -rf ../build/making_*
	@rm -rf *.log *.pdf *.aux

check_xelatex:
	$(info Checking if XELATEX is installed)
	@which xelatex > /dev/null

check_wget :
	$(info Checking if Wget is installed)
	@which wget > /dev/null

fonts: check_wget
	$(info Installing Google Fonts for TEX sources)
	@wget https://www.dropbox.com/s/vi798bfhhtaru2k/Oswald-Bold.ttf?dl=0 -O ../build/Oswald-Bold.ttf
	@wget https://www.dropbox.com/s/nnvq3aeupegzek2/Oswald-Light.ttf?dl=0 -O ../build/Oswald-Light.ttf
	@wget https://www.dropbox.com/s/pi3vo57b7c0upbg/Oswald-Regular.ttf?dl=0 -O ../build/Oswald-Regular.ttf
	@wget https://www.dropbox.com/s/jv3yl7wdrhgnoxy/RobotoSlab-Bold.ttf?dl=0 -O ../build/RobotoSlab-Bold.ttf
	@wget https://www.dropbox.com/s/h8tfnpmxqvf2a2k/RobotoSlab-Light.ttf?dl=0 -O ../build/RobotoSlab-Light.ttf
	@wget https://www.dropbox.com/s/mcyso3hqjt233x9/RobotoSlab-Regular.ttf?dl=0 -O ../build/RobotoSlab-Regular.ttf
	@wget https://www.dropbox.com/s/p5dx7xrfjuwyjmn/RobotoSlab-Thin.ttf?dl=0 -O ../build/RobotoSlab-Thin.ttf
	@wget https://www.dropbox.com/s/dp4q57s11ccepuv/Roboto-Medium.ttf?dl=0 -O ../build/Roboto-Medium.ttf
	@wget https://www.dropbox.com/s/qskbk37q7ocvtem/Roboto-MediumItalic.ttf?dl=0 -O ../build/Roboto-MediumItalic.ttf
ifeq ($(OS),Darwin)
	@mkdir -p ~/Library/Fonts
	@cp ../build/Oswald*.ttf ~/Library/Fonts
	@cp ../build/Roboto*.ttf ~/Library/Fonts
else
	@cp ../build/Oswald*.ttf ~/.fonts
	@cp ../build/Roboto*.ttf ~/.fonts
	@fc-cache -f -v > /dev/null
endif

tex: en_tex sk_tex en_tex_photo
%_tex:
	$(info Building Slide Rule PDF documents from TEX sources, localization $*)
	@cp ../artwork/logo.pdf* ./
	@$(XELATEX) -interaction=batchmode -output-directory=../build/ title_$*.tex > /dev/null
	@$(XELATEX) -interaction=batchmode -output-directory=../build/ making_$*.tex > /dev/null
	@$(XELATEX) -interaction=batchmode -output-directory=../build/ using_$*.tex > /dev/null
	@$(XELATEX) -interaction=batchmode -output-directory=../build/ printing_$*.tex > /dev/null

%_tex_photo:
	$(info Building Photoslide PDF documents from TEX sources, localization $*)
	@$(XELATEX) -interaction=batchmode -output-directory=../build/ using_photo_$*.tex > /dev/null

prepare: clean
	@mkdir -p ../build

