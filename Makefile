.PHONY: clean

# Options to pass to pdflatex
PDFLATEX_OPTS=-halt-on-error

ALL_DOCS=$(wildcard *.tex)
ALL_PDFS=$(addsuffix .pdf,$(basename $(ALL_DOCS)))

# Default target: Build each PDF
$(ALL_PDFS):

clean:
	# Remove all ignored files
	git clean -fX .

# Generic LaTeX build process
%.pdf: %.tex clean
	pdflatex $(PDFLATEX_OPTS) $*
	biber $*
	pdflatex $(PDFLATEX_OPTS) $*
	pdflatex $(PDFLATEX_OPTS) $*
