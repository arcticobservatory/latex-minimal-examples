LaTeX Examples
==================================================

This is a repository of minimal working examples (MWEs) for several LaTeX
tricks, as I pick them up and find them useful.

Originally, many of these were lumped together in one template.
But the template got very bloated, very fast.
So it made more sense to separate them out into
simple examples that could be composed into new documents.

List of Examples
==================================================

### Sanitizing .bib data

[biblatex-transforms-declaresourcemap.tex](biblatex-transforms-declaresourcemap.tex)

An example of how to use Biblatex's DeclareSourcemap command to massage incoming data.
This example specifically tweaks bib data exported from Zotero.
It includes tweaks such as renaming fields, fixing timestamp format, and fixing quote nesting.

![](previews/biblatex-transforms-declaresourcemap.png)

### Chapter/section intro quotes

[epigraphs-and-pull-quotes.tex](epigraphs-and-pull-quotes.tex)

A few examples of "epigraph" pull quotes to introduce chapters or sections.
It shows the use of the epigraph package, and how to roll your own command.

![](previews/epigraphs-and-pull-quotes.png)

### Including git history

[git-log.tex](git-log.tex)

A macro that adds a git log section, as long as the document is not final.
It requires a little help from the Makefile to dump the git log into a file,
but it shows you how to do that and how to input the file.

![](previews/git-log.png)

### Writing prose without having to escape %, &, etc.

[plain-text-prose.tex](plain-text-prose.tex)

A macro that de-fangs LaTeX control characters, so you can write prose without worrying about escaping them.
Especially useful if you need to copy and paste an abstract into a web form when submitting a paper.

![](previews/plain-text-prose.png)

### Setting text aside while rewriting it

[scratch-text-blocks.tex](scratch-text-blocks.tex)

A macro that marks text (even large blocks) for deletion.
Without the `final` option, the text will be greyed out, but left in the document.
With the `final` option, it text will be excluded altogether.

![](previews/scratch-text-blocks.png)
