# Directory configuration
BUILD_DIR = build
ABSTRACT_DIR = abstract
PRESENTATION_DIR = presentation
ARTICLE_DIR = article
IMGS_DIR = imgs

# Directory path combining
ABSTRACT_BUILD_DIR = $(BUILD_DIR)/$(ABSTRACT_DIR)
PRESENTATION_BUILD_DIR = $(BUILD_DIR)/$(PRESENTATION_DIR)
ARTICLE_BUILD_DIR = $(BUILD_DIR)/$(ARTICLE_DIR)
IMGS_BUILD_DIR = $(BUILD_DIR)/$(IMGS_DIR)

# TEX sources
TEX_SRCS := $(wildcard */*.tex)

# Directory guard
dir_guard = @mkdir -p $(@D)

# All recipe
all: abstract presentation figures

### Numeric reports
# Abstract
abstract: $(ABSTRACT_BUILD_DIR)/abstract.pdf

$(ABSTRACT_BUILD_DIR)/abstract.pdf: src/abstract.tex
	$(dir_guard)
	latexmk -pdf -shell-escape -output-directory=$(ABSTRACT_BUILD_DIR) $<

presentation: $(PRESENTATION_BUILD_DIR)/presentation.pdf

$(PRESENTATION_BUILD_DIR)/presentation.pdf: src/presentation.tex figures
	$(dir_guard)
	latexmk -pdfxe -shell-escape -output-directory=$(PRESENTATION_BUILD_DIR) $<

# Figures
IMGS_SVG := $(wildcard ${IMGS_DIR}/*.svg)
IMGS_PDF := $(IMGS_SVG:${IMGS_DIR}/%.svg=${IMGS_BUILD_DIR}/%.pdf)

figures: $(IMGS_PDF)

$(IMGS_BUILD_DIR)/%.pdf: $(IMGS_DIR)/%.svg
	$(dir_guard)
	inkscape --export-pdf=$@ --export-area-drawing --file=$<

# Clean recipe
clean:
	rm -rf $(BUILD_DIR)