.PHONY: clean all

# Options to pass to pdflatex
PDFLATEX_OPTS=-halt-on-error

ALL_DOCS=$(wildcard *.tex)
ALL_PDFS=$(addsuffix .pdf,$(basename $(ALL_DOCS)))

all: clean $(ALL_PDFS)

clean:
	# Remove all ignored files
	git clean -fX .

# Generic LaTeX build process, with biblatex
biblatex-%.pdf: biblatex-%.tex
	pdflatex $(PDFLATEX_OPTS) $<
	biber $(basename $<)
	pdflatex $(PDFLATEX_OPTS) $<
	pdflatex $(PDFLATEX_OPTS) $<

# Generic LaTeX build process, simple
%.pdf: %.tex
	pdflatex $(PDFLATEX_OPTS) $<


# Git log
git-log.pdf: git-log.txt

GIT_HEAD=$(shell git rev-parse --show-toplevel)/.git/logs/HEAD

git-log.txt: $(GIT_HEAD)
	git log --oneline --graph -n10 > git-log.txt
