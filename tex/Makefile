

XELATEX=$(shell which xelatex 2> /dev/null)

all: prepare check_xelatex tex

clean:
	@rm -rf ../build/making_*
	@rm -rf *.log *.pdf *.aux

fonts:
	$(info Installing Google Fonts for TEX sources)
	@wget https://dl.dropboxusercontent.com/u/29576433/fonts/Oswald/Oswald-Bold.ttf -O ../build/Oswald-Bold.ttf
	@wget https://dl.dropboxusercontent.com/u/29576433/fonts/Oswald/Oswald-Light.ttf -O ../build/Oswald-Light.ttf
	@wget https://dl.dropboxusercontent.com/u/29576433/fonts/Oswald/Oswald-Regular.ttf -O ../build/Oswald-Regular.ttf
	@wget https://dl.dropboxusercontent.com/u/29576433/fonts/Roboto_Slab/RobotoSlab-Bold.ttf -O ../build/RobotoSlab-Bold.ttf
	@wget https://dl.dropboxusercontent.com/u/29576433/fonts/Roboto_Slab/RobotoSlab-Light.ttf -O ../build/RobotoSlab-Light.ttf
	@wget https://dl.dropboxusercontent.com/u/29576433/fonts/Roboto_Slab/RobotoSlab-Regular.ttf -O ../build/RobotoSlab-Regular.ttf
	@wget https://dl.dropboxusercontent.com/u/29576433/fonts/Roboto_Slab/RobotoSlab-Thin.ttf -O ../build/RobotoSlab-Thin.ttf
	@wget https://dl.dropboxusercontent.com/u/29576433/fonts/Roboto/Roboto-Medium.ttf -O ../build/Roboto-Medium.ttf
	@wget http://dl.dropboxusercontent.com/u/29576433/fonts/Roboto/Roboto-MediumItalic.ttf -O ../build/Roboto-MediumItalic.ttf
	@cp ../build/Oswald*.ttf ~/.fonts
	@cp ../build/Roboto*.ttf ~/.fonts
	@fc-cache -f -v > /dev/null

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

check_xelatex:
	$(info Checking if XELATEX is installed)
	@which xelatex > /dev/null

prepare: clean
	@mkdir -p ../build

