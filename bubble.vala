
public class Bubbles.Bubble : Clutter.CairoTexture {

	private Cairo.Context cr;
	private int angle;
	private Clutter.Path path;

	public Bubble (Clutter.Color color) {
		angle = Random.int_range (0, 360);
		this.set_anchor_point_from_gravity (Clutter.Gravity.CENTER);
		this.set_surface_size (Main.BUBBLE_RADIUS*2, Main.BUBBLE_RADIUS*2);

		cr = this.create ();
		Clutter.cairo_set_source_color (cr, color);
		cr.arc (Main.BUBBLE_RADIUS, Main.BUBBLE_RADIUS, Main.BUBBLE_RADIUS, 0, Math.PI*2);

		cr.fill ();
		cr = null;

		path = new Clutter.Path ();
		path.move_to (this.x, this.y);
	}
}
		