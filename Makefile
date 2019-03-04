.PHONY: clean all

ALL_TEX=$(wildcard *.tex)
ALL_PDFS=$(addsuffix .pdf,$(basename $(ALL_TEX)))

ALL_PNGS=$(addsuffix .png,$(basename $(ALL_TEX)))
NORMAL_PREVIEWS=$(addprefix previews/,$(ALL_PNGS))

FINAL_PREVIEWS=\
    previews/git-log-final.png \
    previews/scratch-text-blocks-final.png \
    previews/towrite-macro-final.png \


all: $(ALL_PDFS) $(NORMAL_PREVIEWS) $(FINAL_PREVIEWS)

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


# Git log
git-log.pdf: git-log.txt

GIT_HEAD=$(shell git rev-parse --show-toplevel)/.git/logs/HEAD

# This rule has been deliberately updated to rely on a change to the example
# TeX file rather than the actual git log.
# This is because this repository includes a preview PNG of the TeX ouput, and
# it's hard to maintain a clean git history when every commit instantly causes
# a change in one of the checked-in files.
# This way it will only update if we also update the actual example.
#
# For more sensible repositories that don't check in the generated output,
# remove the dependency on git-log.tex and uncomment $(GIT_HEAD)
# (or whatever documents you want to actually trigger an update).
#
git-log.txt: git-log.tex # $(GIT_HEAD)
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


# Create a final version by uncommenting the final option in the documentclass
#
# To use, put "%final" on its own line in the documentclass definition,
# and then ask for whatever-final.tex (or pdf, or png).
# Makes rule inference should take care of the rest.
#
%-final.tex: %.tex
	sed 's/\%final/final/' $< > $@
