# Directory configuration
BUILD_DIR = build
ABSTRACT_DIR = abstract
ARTICLE_DIR = article
FIGURES_DIR = figures

# Directory path combining
ABSTRACT_BUILD_DIR = $(BUILD_DIR)/$(ABSTRACT_DIR)
ARTICLE_BUILD_DIR = $(BUILD_DIR)/$(ARTICLE_DIR)
FIGURES_BUILD_DIR = $(BUILD_DIR)/$(FIGURES_DIR)

# TEX sources
TEX_SRCS := $(wildcard */*.tex)

# Directory guard
dir_guard = @mkdir -p $(@D)

# All recipe
all: abstract

### Numeric reports
# Abstract
abstract: $(ABSTRACT_BUILD_DIR)/abstract.pdf

$(ABSTRACT_BUILD_DIR)/abstract.pdf: src/abstract.tex
	$(dir_guard)
	latexmk -pdf -shell-escape -output-directory=$(ABSTRACT_BUILD_DIR) $<

# Article
# article: $(ARTICLE_BUILD_DIR)/article.pdf

# $(ARTICLE_BUILD_DIR)/article.pdf: src/article.tex
# 	$(dir_guard)
# 	latexmk -pdf -shell-escape -output-directory=$(ARTICLE_BUILD_DIR) $<

# Clean recipe
clean:
	rm -rf $(BUILD_DIR)