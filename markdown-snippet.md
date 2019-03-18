# Text included from Markdown

This text was written in Markdown, converted with Pandoc, and then included in the document.

This is useful for outlines and lists,
since it's more efficient to write lists in Markdown.

1. Create a Markdown file with the name `.md`
2. A generic Make rule uses Pandoc to convert `.md` to `.md.tex`
    a. Remember to include the specific `.md.tex` file as a dependency for your specific PDF,
        to ensure that it is generated
    b. You can also examine the generated `.md.tex` file
        to see the details of the conversion to \LaTeX{}
3. Include the `.md.tex` file in your \LaTeX{} source with `\input`

Note that the Markdown can contain \LaTeX{} commands.
