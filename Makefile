.PHONY: clean all

# Options to pass to pdflatex
PDFLATEX_OPTS=-halt-on-error

ALL_TEX=$(wildcard *.tex)
ALL_PDFS=$(addsuffix .pdf,$(basename $(ALL_TEX)))

ALL_PNGS=$(addsuffix .png,$(basename $(ALL_TEX)))
ALL_PREVIEWS=$(addprefix previews/,$(ALL_PNGS))

all: $(ALL_PDFS) $(ALL_PREVIEWS)

clean:
	# Remove all ignored files
	git clean -fX .


# Generic LaTeX build process, simple
%.pdf: %.tex
	pdflatex $(PDFLATEX_OPTS) $<

# Generic LaTeX build process, with biblatex
biblatex-%.pdf: biblatex-%.tex
	pdflatex $(PDFLATEX_OPTS) $<
	biber $(basename $<)
	pdflatex $(PDFLATEX_OPTS) $<
	pdflatex $(PDFLATEX_OPTS) $<


# Git log
git-log.pdf: git-log.txt

GIT_HEAD=$(shell git rev-parse --show-toplevel)/.git/logs/HEAD

git-log.txt: $(GIT_HEAD)
	git log --oneline --graph -n10 > git-log.txt


# Convert PDF to PNG
#
# Note: We are deliberately discarding the date and time metadata from the PNGs
# so that the output will be deterministic and easier to store in git.
# See https://imagemagick.org/discourse-server/viewtopic.php?f=1&t=34782#p159822
#
%.png: %.pdf
	convert $< \
	    -flatten \
	    -trim \
	    -bordercolor white -border 30x30 \
	    -define png:exclude-chunk=time,date \
	    $@

# Copy to previews subdirectory
previews/%.png: %.png
	mkdir -p previews
	cp $< $@
