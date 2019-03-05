# Makefile for LaTeX examples

# This Makefile leans heavily on rule inference
#
# There are rules to make PDF from TEX, PNG from PDF, and final TEX from TEX.
# The rules combine so that for any x.tex file in this directory, you can make
# x.pdf, x.png, x-final.tex, x-final.pdf, and x-final.png, just by requesting
# them.
#
# To get previews/x.png:
#   x.tex -> x.pdf -> x.png -> previews/x.png
#
# To get to previews/x-final.png:
#   x.tex -> x-final.tex -> x-final.pdf -> x-final.png -> previews/x-final.png
#
# To make PDFs and PNG previews for all .tex files in the directory, we use a
# wildcard to put a list of all .tex files in the ALL_TEX variable, then do
# simple substitution to get the ALL_PDFS (*.pdf), ALL_PNGS (*.png), and
# PREVIEWS (preview/*.png).
#
# A few of the examples have different behavior in final mode, so to make sure
# those are built too, we add '-final.tex' versions of their names manually to
# the ALL_TEX variable. From there, the substitutions make sure they are also
# included in ALL_PDFS, ALL_PNGS, and ALL_PREVIEWS as well.
#
# Finally, the 'all' target depends on building the wildcard-derived lists of
# PDFs (ALL_PDFS) and previews (PREVIEWS), so it builds everything.
#

ALL_TEX=$(wildcard *.tex) \
	git-log-final.tex \
	scratch-text-blocks-final.tex \
	towrite-macro-final.tex \

ALL_PDFS=$(addsuffix .pdf,$(basename $(ALL_TEX)))

ALL_PNGS=$(addsuffix .png,$(basename $(ALL_TEX)))
PREVIEWS=$(addprefix previews/,$(ALL_PNGS))


.PHONY: clean all

all: $(ALL_PDFS) $(PREVIEWS)

clean:
	# Remove all ignored files
	git clean -fX .


# Options to pass to pdflatex
PDFLATEXFLAGS=-halt-on-error

# Generic LaTeX build process, simple
%.pdf: %.tex
	pdflatex $(PDFLATEXFLAGS) $<
	pdflatex $(PDFLATEXFLAGS) $<

# Generic LaTeX build process, with biblatex
biblatex-%.pdf: biblatex-%.tex
	pdflatex $(PDFLATEXFLAGS) $<
	biber $(basename $<)
	pdflatex $(PDFLATEXFLAGS) $<
	pdflatex $(PDFLATEXFLAGS) $<


# Final: create a version with 'final' enabled by adding '-final' to filename
#
# In the document, put "%final" on its own line in the documentclass
# definition. Then ask Make for the filename with '-final' on the end:
# x-final.tex, x-final.pdf, etc.
#
# Make's rule inference should take care of the rest.
#
%-final.tex: %.tex
	sed 's/\%final/final/' $< > $@


# Git log
#

# Include history of only select files
GIT_LOG_DOCS:=git-log.tex

# The git head reference file: updated after every commit and checkout
GIT_HEAD_REF:=$(shell git rev-parse --show-toplevel)/.git/logs/HEAD

# Get the latext version that affects GIT_LOG_DOCS, and dump the version
# (tag+hash via git-describe or just the hash) to a file
GIT_LOG_DOCS_VERSION:=$(shell git log -1 --format="%h" -- $(GIT_LOG_DOCS))
git-describe.txt: $(GIT_HEAD_REF)
	git describe --tags 2>/dev/null $(GIT_LOG_DOCS_VERSION) \
	    || echo "$(GIT_LOG_DOCS_VERSION)" > git-describe.txt

# Get a log of recent history and dump it to a file
git-log.txt: $(GIT_LOG_DOCS) $(GIT_HEAD_REF)
	git log --oneline --graph -n10 -- $(GIT_LOG_DOCS) > git-log.txt

# Add these git files to the dependency lists of the PDFs that include them
git-log.pdf git-log-final.pdf: git-log.txt git-describe.txt


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
