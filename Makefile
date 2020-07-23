# From  https://tex.stackexchange.com/questions/40738/how-to-properly-make-a-latex-project
# -----------------------------------------------------------------------------
# You want latexmk to *always* run, because make does not have all the info.
# Also, include non-file targets in .PHONY so they are run regardless of any
# file of the given name existing.
.PHONY: clean

# The first rule in a Makefile is the one executed by default ("make"). It
# should always be the "all" rule, so that "make" and "make all" are identical.

all: article
article: article.pdf Roukema_ReSciC2020.pdf
Roukema_ReSciC2020.pdf: article.pdf


# CUSTOM BUILD RULES
# -----------------------------------------------------------------------------
metadata.tex: metadata.yaml
	./yaml-to-latex.py -i $< -o metadata.tex.tmp \
	  && sed -e 's,%26,\\%26,g' metadata.tex.tmp > $@


# MAIN LATEXMK RULE
# -----------------------------------------------------------------------------
# -pdf tells latexmk to generate PDF directly (instead of DVI).
# -pdflatex="" tells latexmk to call a specific backend with specific options.
# -use-make tells latexmk to call make for generating missing files.
# -interaction=nonstopmode keeps the pdflatex backend from stopping at a
# missing file reference and interactively asking you for an alternative.

article.pdf: article.tex content.tex bibliography.bib metadata.tex rescience.cls
	latexmk -pdf -pdflatex="xelatex -interaction=nonstopmode" -use-make article.tex
	cp -pv article.pdf Roukema_ReSciC2020.pdf

arxiv: arXiv

# Choose a name
arXivable_tex = Roukema_ReSciC2020.tex


arXiv: article.tex metadata.tex
	# Generic: this part should apply to most articles:
	cp -v metadata.tex metadata-tmp.tex
	sed -e 's/¬/{$$\\neg$$}/' -e "s/é/{\\\\'e}/" -e "s/ń/{\\\\'n}/" \
	  -e 's/–/--/' metadata-tmp.tex > metadata.tex
	latexpand --makeatletter article.tex > article-fix-1.tex
	sed -e 's/supercite/cite/g'  -e "s/é/{\\\\'e}/" \
	   -e 's/\(grant 314\.\)/\1\\sloppy/' \
	   article-fix-1.tex  > article-fix-2.tex
	latex article-fix-2
	bibtex article-fix-2
	sed -e 's/%26/\\%26/g' -e 's/dx\.doi\.org/oadoi\.org/g' \
	   article-fix-2.bbl > article-fix-2b.bbl
	latexpand  --makeatletter --expand-bbl article-fix-2b.bbl article-fix-2.tex > article-fix-3.tex
	## Hardwired article-specific hacks to handle what breakurl cannot handle.
	sed -e "s/\'/EOL/g" article-fix-3.tex | tr -d '\n' | \
	   sed -e 's/\(.mn.doi[^}]*National Academy[^}]*}\)/\\mbox{\1}/' \
	   -e 's/\(.href[^}]*\(rescience\.github\|investigating.archiving\)[^}]*}[^}]*}\)/\\mbox{\1}/' \
	   -e 's/EOL/\n/g' > article-fix-4.tex
	## Return to generic section
	latex article-fix-4 \
	  && latex article-fix-4 \
	  && mv -v article-fix-4.tex $(arXivable_tex) \
	  && tar -cvz -f arXiv.tgz $(arXivable_tex) metadata.tex rescience.cls \
	  && cp -pv arXiv.tgz /tmp \
	  && ls -l arXiv.tgz /tmp/arXiv.tgz

clean:
	@latexmk -CA
	@rm -f *.bbl
	@rm -f *.run.xml
	@rm -f metadata.tex
