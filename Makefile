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
# See the comments in git-log.tex for details

# The documents in the GIT_LOG_DOCS variable will be used as both Make
# dependencies and to limit the printed git history to only those files.
GIT_LOG_DOCS:=git-log.tex

# The git head reference file will be updated after every commit and checkout
GIT_HEAD_REF:=$(shell git rev-parse --show-toplevel)/.git/logs/HEAD

# git-describe.txt will contain a description of the latest version that
# touched GIT_LOG_DOCS, including tags
GIT_LOG_DOCS_VERSION:=$(shell git log -1 --format="%h" -- $(GIT_LOG_DOCS))
git-describe.txt: $(GIT_HEAD_REF)
	git describe --tags 2>/dev/null $(GIT_LOG_DOCS_VERSION) \
	    || echo "$(GIT_LOG_DOCS_VERSION)" > git-describe.txt

# git-log.txt will contain a log of recent commits that affected GIT_LOG_DOCS
git-log.txt: $(GIT_LOG_DOCS) $(GIT_HEAD_REF)
	git log --oneline --graph -n10 -- $(GIT_LOG_DOCS) > git-log.txt

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


# Create a final version by uncommenting the final option in the documentclass
#
# To use, put "%final" on its own line in the documentclass definition,
# and then ask for whatever-final.tex (or pdf, or png).
# Makes rule inference should take care of the rest.
#
%-final.tex: %.tex
	sed 's/\%final/final/' $< > $@
