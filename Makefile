.PHONY: fonts tex

OS=$(shell uname -s)
BRAND="creat.io-sr-m1a2"

# workaround for Rasem's inability to produce units in the result SVG
APPLYMM=sed -e 's/" height=/mm" height=/' -e 's/" viewBox=/mm" viewBox=/'

# postprocessing commands for Inkscape SVG ouput
POSTPROCESS=| $(APPLYMM) | xmllint --format -

ifeq ($(OS),Darwin)
	INKSCAPE="/Applications/Inkscape.app/Contents/Resources/bin/inkscape"
else
	INKSCAPE=$(shell which inkscape 2> /dev/null)
endif

all : prerequisites prepare fonts tex model_a

clean :
	@rm -rf build
	make -C tex clean

print_os :
	$(info Detected operating system: $(OS))

check_ruby :
	$(info Checking if Ruby is installed)
	@which ruby > /dev/null

check_rasem :
	$(info Checking if Ruby Gem Rasem is installed)
	@gem list | grep rasem > /dev/null

check_rqrcode :
	$(info Checking if Ruby Gem RQRCode is installed)
	@gem list | grep rqrcode > /dev/null

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

LANGUAGES = en sk

# Builds printouts for Instrument A
model_a : en_model_a_default sk_model_a_default en_model_a_colored sk_model_a_colored
model_a_photo: en_model_a_photo sk_model_a_photo

define model_a_template
$(1)_model_a_$(2) :
	@echo "Generating Instrument A, localization $(1), style $(2)"
	@src/model_a.rb $(2) $(1) stock face $(POSTPROCESS) > build/$(1)_model_a_stock_face_$(2).svg
	@src/model_a.rb $(2) $(1) stock reverse $(POSTPROCESS) > build/$(1)_model_a_stock_reverse_$(2).svg 
	@src/model_a.rb $(2) $(1) slide-math face $(POSTPROCESS) > build/$(1)_model_a_slide_face_$(2).svg
	@src/model_a.rb $(2) $(1) slide-math reverse $(POSTPROCESS) > build/$(1)_model_a_slide_reverse_$(2).svg 
	@src/model_a.rb $(2) $(1) transp face $(POSTPROCESS) > build/$(1)_model_a_transp_face_$(2).svg
	@src/model_a.rb $(2) $(1) transp reverse $(POSTPROCESS) > build/$(1)_model_a_transp_reverse_$(2).svg 
	@$(INKSCAPE) -z -A $(shell pwd)/build/$(1)_model_a_stock_face_$(2).pdf $(shell pwd)/build/$(1)_model_a_stock_face_$(2).svg
	@$(INKSCAPE) -z -A $(shell pwd)/build/$(1)_model_a_stock_reverse_$(2).pdf $(shell pwd)/build/$(1)_model_a_stock_reverse_$(2).svg
	@$(INKSCAPE) -z -A $(shell pwd)/build/$(1)_model_a_slide_face_$(2).pdf $(shell pwd)/build/$(1)_model_a_slide_face_$(2).svg
	@$(INKSCAPE) -z -A $(shell pwd)/build/$(1)_model_a_slide_reverse_$(2).pdf $(shell pwd)/build/$(1)_model_a_slide_reverse_$(2).svg
	@$(INKSCAPE) -z -A $(shell pwd)/build/$(1)_model_a_transp_face_$(2).pdf $(shell pwd)/build/$(1)_model_a_transp_face_$(2).svg
	@$(INKSCAPE) -z -A $(shell pwd)/build/$(1)_model_a_transp_reverse_$(2).pdf $(shell pwd)/build/$(1)_model_a_transp_reverse_$(2).svg
	@gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile=build/$(1)_model_a_$(2).pdf \
		build/title_$(1).pdf \
		build/$(1)_model_a_stock_face_$(2).pdf \
		build/$(1)_model_a_stock_reverse_$(2).pdf \
		build/$(1)_model_a_stock_face_$(2).pdf \
		build/$(1)_model_a_stock_reverse_$(2).pdf \
		build/$(1)_model_a_slide_face_$(2).pdf \
		build/$(1)_model_a_slide_reverse_$(2).pdf \
		build/$(1)_model_a_slide_face_$(2).pdf \
		build/$(1)_model_a_slide_reverse_$(2).pdf \
		build/$(1)_model_a_transp_face_$(2).pdf \
		build/$(1)_model_a_transp_reverse_$(2).pdf \
		build/printing_$(1).pdf \
		build/making_$(1).pdf \
		build/using_$(1).pdf \
		build/using_$(1).pdf
	@cp build/$(1)_model_a_$(2).pdf build/$(BRAND)-$(1)-$(2).pdf
	@echo "Result PDF: build/$(BRAND)-$(1)-$(2).pdf"
endef

$(eval $(call model_a_template,en,default))
$(eval $(call model_a_template,sk,default))
$(eval $(call model_a_template,en,colored))
$(eval $(call model_a_template,sk,colored))

%_model_a_photo :
	$(info Generating photo Slide of Instrument A, localization $* )
	@src/model_a.rb default $* slide-photo face | $(APPLYMM) > build/$*_model_a_slide_photo_face.svg
	@src/model_a.rb default $* slide-photo reverse | $(APPLYMM) > build/$*_model_a_slide_photo_reverse.svg
	@$(INKSCAPE) -z -A $(shell pwd)/build/$*_model_a_slide_photo_face.pdf $(shell pwd)/build/$*_model_a_slide_photo_face.svg
	@$(INKSCAPE) -z -A $(shell pwd)/build/$*_model_a_slide_photo_reverse.pdf $(shell pwd)/build/$*_model_a_slide_photo_reverse.svg
	@gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile=build/$*_model_a_slide_photo.pdf build/$*_model_a_slide_photo_face.pdf build/$*_model_a_slide_photo_reverse.pdf
	@cp build/$*_model_a_slide_photo.pdf build/$(BRAND)-$*-photo.pdf
	@echo "Result PDF: build/$(BRAND)-$*-photo.pdf"

model_a_debug :
	@echo "Generating debug (all layers) SVG's of Instrument A"
	@src/model_a.rb default en stock both $(POSTPROCESS) > build/model_a_stock_both.svg
	@src/model_a.rb default en slide-math both $(POSTPROCESS) > build/model_a_slide_both.svg
	@src/model_a.rb default en transp both $(POSTPROCESS) > build/model_a_transp_both.svg
	@echo "Result SVG's are in directory 'build', suffixed '_both.svg'"
	@echo "Use 'ls -la build/*_both.svg' to list them"

prerequisites : print_os check_ruby check_rasem check_rqrcode check_xmllint check_inkscape check_gs

prepare:
	@mkdir -p build
	@cp artwork/logo.svg build/logo.svg

