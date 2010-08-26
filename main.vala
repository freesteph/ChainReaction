using GtkClutter;
using Gee;

public class Bubbles.Main {

	protected const int BUBBLE_RADIUS = 10;
	protected const int BUBBLE_RADIUS_EXPANDED = 30;
	protected const int BUBBLE_OPACITY = 200;

	public static int main (string []args) {
		GtkClutter.init (ref args);
		
		var board = new Board (30);
		board.run ();

		Gtk.main ();
		return 0;
	}

}
