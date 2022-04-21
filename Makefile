.PHONY: all images css

all: css images

css: site/css/main.css site/css/reset.css

site/css/%.css: src/css/%.css
	cp $^ $@

images: site/images/logo-34.png site/images/logo-85.png

site/images/logo-%.png: src/images/logo.png
	respimg src/images/logo.png site/images/logo $*
