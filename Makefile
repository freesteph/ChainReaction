BUBBLE_PACKAGES=--pkg clutter-gtk-0.10 \
		--pkg gee-1.0

bubble: bubble.vala board.vala main.vala
	valac *.vala $(BUBBLE_PACKAGES) -g -X -lm -o bubble
