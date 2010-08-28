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
	private Gee.ArrayList<Clutter.Knot?> frozen_points;
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
			b.move ();

			population--;
		}

		frozen_points = new Gee.ArrayList<Clutter.Knot?> ();
		pointer = new CursorBubble ({ 0, 0, 0, 255 });
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
			Clutter.Knot coords = ({ (int)pointer.x, (int)pointer.x });
			frozen_points.add (coords);
			foreach (BubbleOther b in bubbles) {
				b.new_position.connect (_on_bubble_position_at_freeze);
			}
			this.pointer.expand ();
		}
		return true;
	}

	public void _on_bubble_position_at_freeze (BubbleOther b) {
		foreach (Clutter.Knot knot in frozen_points) {
			if ((Math.fabs (b.x - knot.x) <= Bubble.RADIUS*2) &&
				(Math.fabs (b.y - knot.y) <= Bubble.RADIUS*2)) {
				/* the center of the bubbles are close enough to collide */
				b.stop ();
				b.expand ();
				bubbles.remove (b);
				Clutter.Knot coords = { (int)b.x, (int)b.y };
				frozen_points.add (coords);
				break;
			}
		}
	}

	public void _on_bubble_path_complete (BubbleOther b) {
		b.path.clear ();
		calculate_path (b);
		b.move ();
	}

	private void calculate_path (BubbleOther b) {
		double dx, dy;
		double opposite;
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
				dy = 0;
			} else {
				/* we're hitting the right edge */
				dx = w;
				dy = y - opposite;
			}
		} else if (angle < Math.PI) {
			/* up-left */
			opposite = Math.tan (angle - Math.PI/2) * y;
			if (x - opposite < 0) {
				/* right hit */
				opposite = Math.tan (Math.PI - angle) * x;
				dx = 0;
				dy = y - opposite;
			} else {
				/* top hit */
				horizontal_hit = true;
				dy = 0;
				dx = x - opposite;
			}
		} else if (angle < Math.PI*1.5) {
			/* down-left */
			opposite = Math.tan (angle - Math.PI) * x;
			if (y + opposite > h) {
				/* bottom hit */
				horizontal_hit = true;
				opposite = Math.tan (Math.PI*1.5 - angle) * (h - x);
				dx = x - opposite;
				dy = h;
			} else {
				/* right hit */
				dx = 0;
				dy = y + opposite;
			}
		} else {
			/* down-right */
			opposite = Math.tan (angle - Math.PI*1.5) * (h - y);
			if (x + opposite > w) {
				/* left hit */
				opposite = Math.tan (Math.PI*2 - angle) * (h - x);
				dx = w;
				dy = y + opposite;
			} else {
				/* bottom hit */
				horizontal_hit = true;
				dx = x + opposite;
				dy = h;
			}
		}

		if (horizontal_hit) {
			angle = Math.PI*2 - angle;
		} else {
			angle = Math.PI - angle;
			if (angle < 0) (angle += Math.PI*2);
		}

		b.angle = angle;
		//FIXME : why does the distance go negative sometimes ?
		// assert (dx >= 0 && dx <= w);
		// assert (dy >= 0 && dy <= h);
		b.path.add_move_to ((int)b.x, (int)b.y);
		b.path.add_line_to ((int)dx, (int)dy);
	}
}
