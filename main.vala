using GtkClutter;
using Gee;

public class Bubbles.Main {

	public static int main (string []args) {
		GtkClutter.init (ref args);
		
		var board = new Board (30);
		board.run ();

		Gtk.main ();
		return 0;
	}

}
