using GtkClutter;

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
	private Gee.ArrayList<Bubble> frozen;
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
			b = new BubbleOther (this.stage,  { red, green, blue, 255 });

			bubbles.add (b);
			stage.add_actor (b);
			//FIXME : constant
			x = Random.int_range (0, (int)stage.width - 30);
			y = Random.int_range (0, (int)stage.height - 30);
			b.set_position ((int)x, (int)y);
			b.move ();

			population--;
		}

		pointer = new CursorBubble (this.stage, { 0, 0, 0, 255 });
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
			this.pointer.expand ();
		}
		return true;
	}
}
