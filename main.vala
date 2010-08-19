using GtkClutter;

public class Bubble.Main {

	
	public static int main (string []args) {
		GtkClutter.init (ref args);
		
		var board = new Board ();
		board.run ();

		Gtk.main ();
		return 0;
	}

	public static Clutter.Color[]? generate_colors () {
		return null;
	}
}
