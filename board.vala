using GtkClutter;

/* TODO : implement levels */
/* TODO : implement difficulty */
/* TODO : implement announce ("get 2 of 10 bubbles") */
public class Bubbles.Board {

	/* widget */
	private Gtk.Window window;
	private Gtk.VBox vbox;
	private GtkClutter.Embed embed;
	private Gtk.Builder builder;

	/* actors */
	private Clutter.Stage stage;

	/* data */
	public static bool freeze = false;
	private uint population;
	private Gee.ArrayList<BubbleOther> bubbles;
	private Gee.ArrayList<Bubble> frozen_bubbles;
	private CursorBubble pointer;

	// linked list ? FIXME

	public Board (uint pop) {
		population = pop;

		builder = new Gtk.Builder ();
		try {
			builder.add_from_file ("bubble.ui");
		} catch (Error e) {
			error ("Unable to load UI file: %s", e.message);
		}

		window = builder.get_object ("window1") as Gtk.Window;
		vbox = builder.get_object ("vbox1") as Gtk.VBox;

		embed = new GtkClutter.Embed ();
		embed.set_size_request (640, 480);
		stage = embed.get_stage () as Clutter.Stage;

		vbox.pack_start (embed, true, true);
	}

	public void run () {
		assert (window != null);

		bubbles = new Gee.ArrayList <BubbleOther> ();
		uint8 red, green, blue;
		int x,y;
		BubbleOther b;

		while (population > 0) {
			red = (uint8)Random.int_range (0, 255);
			green = (uint8)Random.int_range (0, 255);
			blue = (uint8)Random.int_range (0, 255);
			b = new BubbleOther ({ red, green, blue, 255 });

			bubbles.add (b);
			this.stage.add_actor (b);
			//FIXME : constant
			x = Random.int_range (0, (int)stage.width - 30);
			y = Random.int_range (0, (int)stage.height - 30);
			b.set_position ((int)x, (int)y);
			calculate_path (b);
			b.path_complete.connect (_on_bubble_path_complete);
			b.end_expansion.connect (_on_bubble_fadeout);
			b.move ();

			population--;
		}

		frozen_bubbles = new Gee.ArrayList<Bubble> ();
		pointer = new CursorBubble ({ 0, 0, 0, 255 });
		pointer.end_expansion.connect (_on_bubble_fadeout);
		this.stage.add_actor (pointer);

		/* events */
		this.stage.motion_event.connect (_on_motion_event);
		this.stage.button_press_event.connect (_on_button_press_event);
		window.show_all ();
	}

	public bool _on_motion_event (Clutter.MotionEvent event) {
		if (!freeze) {
			this.pointer.set_position (event.x, event.y);
		}
		return true;
	}

	public bool _on_button_press_event (Clutter.ButtonEvent event) {
		if (!freeze) {
			freeze = true;
			frozen_bubbles.add (pointer);
			foreach (BubbleOther b in bubbles) {
				b.new_position.connect (_on_bubble_position_at_freeze);
			}
			this.pointer.expand ();
		}
		return true;
	}

	public void _on_bubble_position_at_freeze (BubbleOther b) {
		foreach (Bubble frozen in frozen_bubbles) {
			if ((Math.fabs (b.x - frozen.x) <= Bubble.RADIUS*2) &&
				(Math.fabs (b.y - frozen.y) <= Bubble.RADIUS*2)) {
				/* the center of the bubbles are close enough to collide */
				b.stop ();
				b.expand ();
				bubbles.remove (b);
				frozen_bubbles.add (b);
				break;
			}
		}
	}

	public void _on_bubble_path_complete (BubbleOther b) {
		b.path.clear ();
		calculate_path (b);
		b.move ();
	}

	public void _on_bubble_fadeout (Bubble b) {
		b.fadeout ();
		frozen_bubbles.remove (b);
	}

	private void calculate_path (BubbleOther b) {
		double dx, dy;
		double opposite;
		/* REVIEW : here I store a lot of properties into local variables
		   to avoid some implicit function calls */
		double radius = Bubble.RADIUS * b.scale_x;
		double x = b.x;
		double y = b.y;
		double w = this.stage.width;
		double h = this.stage.height;
		double angle = b.angle;
		bool horizontal_hit = false;

		// FIXME : correct offset bouncing.
		if (angle < Math.PI/2) {
			/* We're going up-right */
			opposite = Math.tan (angle) * (w - x);
			if (y - opposite < 0) {
				/* we're hitting the top */
				horizontal_hit = true;
				opposite = Math.tan (Math.PI/2 - angle) * y;
				dx = x + opposite;
				dy = 0 + radius;
			} else {
				/* we're hitting the right edge */
				dx = w - radius;
				dy = y - opposite;
			}
		} else if (angle < Math.PI) {
			/* up-left */
			opposite = Math.tan (angle - Math.PI/2) * y;
			if (x - opposite < 0) {
				/* left hit */
				opposite = Math.tan (Math.PI - angle) * x;
				dx = 0 + radius;
				dy = y - opposite;
			} else {
				/* top hit */
				horizontal_hit = true;
				dy = 0 + radius;
				dx = x - opposite;
			}
		} else if (angle < Math.PI*1.5) {
			/* down-left */
			opposite = Math.tan (angle - Math.PI) * x;
			if (y + opposite > h) {
				/* bottom hit */
				horizontal_hit = true;
				opposite = Math.tan (Math.PI*1.5 - angle) * (h - y);
				dx = x - opposite;
				dy = h - radius;
			} else {
				/* left hit */
				dx = 0 + radius;
				dy = y + opposite;
			}
		} else {
			/* down-right */
			opposite = Math.tan (angle - Math.PI*1.5) * (h - y);
			if (x + opposite > w) {
				/* right hit */
				opposite = Math.tan (Math.PI*2 - angle) * (w - x);
				dx = w - radius;
				dy = y + opposite;
			} else {
				/* bottom hit */
				horizontal_hit = true;
				dx = x + opposite;
				dy = h - radius;
			}
		}

		if (horizontal_hit) {
			angle = Math.PI*2 - angle;
		} else {
			angle = Math.PI - angle;
			if (angle < 0) (angle += Math.PI*2);
		}

		b.angle = angle;

		/* debug ("Next point is %i, %i", (int)dx, (int)dy);
		   assert (dx >= 0);
		   assert (dx <= w);
		   assert (dy >= 0);
		   assert (dy <= h); */
		b.path.add_move_to ((int)b.x, (int)b.y);
		b.path.add_line_to ((int)dx, (int)dy);
	}
}
