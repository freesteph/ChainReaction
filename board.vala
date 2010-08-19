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
	private uint population;
	private Gee.ArrayList<Bubble> bubbles;

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

		bubbles = new Gee.ArrayList <Bubble> ();
		uint8 red, green, blue;
		var b = new Bubble (Clutter.Color.from_string ("red"));
		while (population > 0) {
			bubbles.add (b);
			red = (uint8)Random.int_range (0, 255);
			green = (uint8)Random.int_range (0, 255);
			blue = (uint8)Random.int_range (0, 255);
			b = new Bubble ( { red, green, blue, 255 } );
			population--;
		}

		int x, y;
		foreach (Bubble bubble in bubbles) {
			stage.add_actor (bubble);
			x = Random.int_range (0, (int)stage.width - Main.BUBBLE_RADIUS);
			y = Random.int_range (0, (int)stage.height - Main.BUBBLE_RADIUS);
			bubble.set_position ((int)x, (int)y);
		}

		window.show_all ();
	}
}
