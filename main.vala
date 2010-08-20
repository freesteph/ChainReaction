using GtkClutter;
using Gee;

public class Bubbles.Main {

	protected const int BUBBLE_RADIUS = 30;
	protected const int BUBBLE_WIDTH_EXPANDED = 50;
	protected const int BUBBLE_OPACITY = 200;

	public static int main (string []args) {
		GtkClutter.init (ref args);
		
		var board = new Board (100);
		board.run ();

		Gtk.main ();
		return 0;
	}

}
