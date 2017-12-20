
OS=$(shell uname -s)
XELATEX=$(shell which xelatex 2> /dev/null)

ifeq ($(OS),Darwin)
define checksum
	md5 $(1) | awk '{print $$4}'
endef
else
define checksum
	md5sum $(1) | awk '{print $$1}'
endef
endif

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

fonts_clean:
	@rm -rf ../build/Oswald*.ttf
	@rm -rf ../build/OpenSansCondensed*.ttf
	@rm -rf ../build/EBGaramond*.ttf

fonts: check_wget
	$(info Installing Google Fonts for TEX sources)
	@[ "`$(call checksum, ../build/Oswald-Bold.ttf)`" == "8993e4d87124a3808ae68d2e52d27f87" ] || wget https://www.dropbox.com/s/vi798bfhhtaru2k/Oswald-Bold.ttf?dl=0 -O ../build/Oswald-Bold.ttf
	@[ "`$(call checksum, ../build/Oswald-Light.ttf)`" == "8dece29a87d3dd3a60cac0023952f1ac" ] || wget https://www.dropbox.com/s/nnvq3aeupegzek2/Oswald-Light.ttf?dl=0 -O ../build/Oswald-Light.ttf
	@[ "`$(call checksum, ../build/Oswald-Regular.ttf)`" == "dab2e777c19906ddc8d3ad983ca79cf0" ] || wget https://www.dropbox.com/s/pi3vo57b7c0upbg/Oswald-Regular.ttf?dl=0 -O ../build/Oswald-Regular.ttf
	@[ "`$(call checksum, ../build/OpenSansCondensed-Bold.ttf)`" == "0c7cbd1ce910eff8b4ec96abd62ac070" ] || wget https://www.dropbox.com/s/dwfedyqrps7zahu/OpenSansCondensed-Bold.ttf?dl=0 -O ../build/OpenSansCondensed-Bold.ttf
	@[ "`$(call checksum, ../build/OpenSansCondensed-Light.ttf)`" == "998fd50b24f86d4f7307c776191f701d" ] || wget https://www.dropbox.com/s/207a09ymaio4rfz/OpenSansCondensed-Light.ttf?dl=0 -O ../build/OpenSansCondensed-Light.ttf
	@[ "`$(call checksum, ../build/OpenSansCondensed-LightItalic.ttf)`" == "cb055480313c58c6a9330ee7cc36488a" ] || wget https://www.dropbox.com/s/4qc7y4tc92dbp8v/OpenSansCondensed-LightItalic.ttf?dl=0 -O ../build/OpenSansCondensed-LightItalic.ttf
	@[ "`$(call checksum, ../build/EBGaramond-Regular.ttf)`" == "7eef6619ba7fe2c594bee19db88661d3" ] || wget https://www.dropbox.com/s/zhqoi3hdn87m335/EBGaramond-Regular.ttf?dl=0 -O ../build/EBGaramond-Regular.ttf
ifeq ($(OS),Darwin)
	@mkdir -p ~/Library/Fonts
	@cp ../build/Oswald*.ttf ~/Library/Fonts
	@cp ../build/OpenSansCondensed*.ttf ~/Library/Fonts
	@cp ../build/EBGaramond*.ttf ~/Library/Fonts
else
	@cp ../build/Oswald*.ttf ~/.fonts
	@cp ../build/OpenSansCondensed*.ttf ~/.fonts
	@cp ../build/EBGaramond*.ttf ~/.fonts
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

