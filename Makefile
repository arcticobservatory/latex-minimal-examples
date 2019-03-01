.PHONY: clean all

ALL_TEX=$(wildcard *.tex)
ALL_PDFS=$(addsuffix .pdf,$(basename $(ALL_TEX)))

ALL_PNGS=$(addsuffix .png,$(basename $(ALL_TEX)))
ALL_PREVIEWS=$(addprefix previews/,$(ALL_PNGS))

all: $(ALL_PDFS) $(ALL_PREVIEWS)

clean:
	# Remove all ignored files
	git clean -fX .


# Options to pass to pdflatex
PDFLATEXFLAGS=-halt-on-error

# Generic LaTeX build process, simple
%.pdf: %.tex
	pdflatex $(PDFLATEXFLAGS) $<

# Generic LaTeX build process, with biblatex
biblatex-%.pdf: biblatex-%.tex
	pdflatex $(PDFLATEXFLAGS) $<
	biber $(basename $<)
	pdflatex $(PDFLATEXFLAGS) $<
	pdflatex $(PDFLATEXFLAGS) $<


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
# Page numbers will screw up the auto-cropping (-trim). To avoid page numbers,
# be sure to include "\thispagestyle{empty}" after the documentclass
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
