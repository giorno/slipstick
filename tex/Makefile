

XELATEX=$(shell which xelatex 2> /dev/null)

all: prepare check_xelatex tex

clean:
	@rm -rf ../build/making_*

tex:
	$(info Building PDF documents from TEX sources)
	@$(XELATEX) -interaction=batchmode -output-directory=../build/ making_en.tex > /dev/null
	@$(XELATEX) -interaction=batchmode -output-directory=../build/ using_en.tex > /dev/null

check_xelatex:
	$(info Checking if XELATEX is installed)
	@which xelatex > /dev/null

prepare: clean
	@mkdir -p ../build

