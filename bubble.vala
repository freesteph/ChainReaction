
public class Bubbles.Bubble : Clutter.CairoTexture {

	private Cairo.Context cr;

	public Bubble (Clutter.Color color) {
		this.set_surface_size (Main.BUBBLE_RADIUS, Main.BUBBLE_RADIUS);

		cr = this.create ();
		Clutter.cairo_set_source_color (cr, color);
		cr.translate (Main.BUBBLE_RADIUS/2, Main.BUBBLE_RADIUS/2);
		cr.arc (0, 0, Main.BUBBLE_RADIUS, 0, 360);
		cr.fill ();
		cr = null;
	}
}
		