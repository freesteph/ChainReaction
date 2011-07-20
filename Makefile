BUBBLE_PACKAGES=--pkg clutter-gtk-1.0 \
		--pkg gee-1.0

bubble: bubble.vala board.vala main.vala bubble-cursor.vala bubble-others.vala
	valac *.vala $(BUBBLE_PACKAGES) -g -X -lm -o bubble

clean:
	rm -rf *.c *~ bubble

todo:
	grep "TODO" *.vala --color
fixme:
	grep "FIXME" *.vala --color
