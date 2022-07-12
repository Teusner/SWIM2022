# Directory configuration
BUILD_DIR = build
ABSTRACT_DIR = abstract
PRESENTATION_DIR = presentation
ARTICLE_DIR = article
IMGS_DIR = imgs
VIDEOS_DIR = videos

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
all: abstract presentation figures videos manim

### Numeric reports
# Abstract
abstract: $(ABSTRACT_BUILD_DIR)/abstract.pdf

$(ABSTRACT_BUILD_DIR)/abstract.pdf: src/abstract.tex
	$(dir_guard)
	latexmk -pdf -shell-escape -output-directory=$(ABSTRACT_BUILD_DIR) $<

presentation: $(PRESENTATION_BUILD_DIR)/presentation.pdf

$(PRESENTATION_BUILD_DIR)/presentation.pdf: src/presentation.tex figures videos manim
	$(dir_guard)
	latexmk -pdfxe -shell-escape -output-directory=$(PRESENTATION_BUILD_DIR) $<

# Figures
IMGS_SVG := $(wildcard ${IMGS_DIR}/*.svg)
IMGS_PDF := $(IMGS_SVG:${IMGS_DIR}/%.svg=${IMGS_BUILD_DIR}/%.pdf)

figures: $(IMGS_PDF)

$(IMGS_BUILD_DIR)/%.pdf: $(IMGS_DIR)/%.svg
	$(dir_guard)
	inkscape --export-pdf=$@ --export-area-drawing --file=$<

# Videos
videos: $(PRESENTATION_BUILD_DIR)/causal.mp4 $(PRESENTATION_BUILD_DIR)/acausal.mp4 ${PRESENTATION_BUILD_DIR}/focus_1.mp4 ${PRESENTATION_BUILD_DIR}/focus_2.mp4

$(PRESENTATION_BUILD_DIR)/focus_1.mp4 : $(VIDEOS_DIR)/causal.mp4
	$(dir_guard)
	/usr/bin/ffmpeg -ss 7 -i $< -c:v libx265 -crf 28 -t 3 $@

$(PRESENTATION_BUILD_DIR)/focus_2.mp4 : $(VIDEOS_DIR)/causal.mp4
	$(dir_guard)
	/usr/bin/ffmpeg -ss 45 -i $< -c:v libx265 -crf 28 -t 5 $@

$(PRESENTATION_BUILD_DIR)/causal.mp4: $(VIDEOS_DIR)/causal.mp4
	$(dir_guard)
	cp -f $< $@

$(PRESENTATION_BUILD_DIR)/acausal.mp4: $(VIDEOS_DIR)/acausal.mp4
	$(dir_guard)
	cp -f $< $@

# Manim
manim: $(PRESENTATION_BUILD_DIR)/introduction.mp4 $(IMGS_BUILD_DIR)/introduction.png

$(PRESENTATION_BUILD_DIR)/introduction.mp4 : scripts/main.py
	$(dir_guard)
	manim -qh -r 1000,1000 $< introduction
	cp -f build/manim/videos/main/1000p60/introduction.mp4 $@

$(IMGS_BUILD_DIR)/introduction.png : scripts/main.py
	$(dir_guard)
	manim -sqh -r 1000,1000 $< introduction
	cp -f build/manim/images/main/introduction_ManimCE_v0.15.2.png $@

# Clean recipe
clean:
	rm -rf $(BUILD_DIR)