.DEFAULT_GOAL := help

.PHONY: zip build html css clean org-based tags category tag-source category-source templates

zip: public
	cd public/ && 7z a ../public.zip .

public: build
	@rm public -r || true
	raco pollen publish . $(HOME)/public
	mv ~/public .

build: html css

html: templates tags category css org
	raco pollen render -p index.ptree

css: css/main.css.pp
	raco pollen render css/main.css.pp

clean:
	git clean -Xdf

# * Turning Org files into Pollen Markup files
# We cannot use .pmd because Tag functions don't work there.
# We cannot use .pp.md because then the tag functions have to return Markdown.
# Ultimately we need a Org -> Pollen Markup converter.
# ORG = $(patsubst %.org,%.html.pm,$(wildcard *.org))
# org: $(ORG)
# $(ORG): %.html.pm: %.org
# 	emacs "$<" --batch -f ox-pollen-export-to-pollen --kill

EXPORTED-FROM-ORG := about.html.pm index.html.pm projects.html.pm

$(EXPORTED-FROM-ORG): %.html.pm: %.org
	cask emacs "$<" --batch -l ox-pollen -f ox-pollen-export-to-pollen --kill

org: $(EXPORTED-FROM-ORG)

# * Tags and Categories
tag-source:
	racket make-tag-pages.rkt

tags: tag-source
	raco pollen render tags/*.pm

category-source:
	racket make-category-pages.rkt

category: category-source
	raco pollen render category/*.pm

# * Templates
templates: template.html

template.html:
	raco pollen render main-template.html.pp
	mv main-template.html template.html
