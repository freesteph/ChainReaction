public class Bubbles.Bubble : Clutter.CairoTexture {

	private Cairo.Context cr;
	private int angle;

	private Clutter.Path path;
	private Clutter.BehaviourPath behaviour;
	private Clutter.Alpha alpha;
	private Clutter.Timeline timeline;

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

		timeline = new Clutter.Timeline (5000);
		timeline.loop = true;

		alpha = new Clutter.Alpha.full (timeline, Clutter.AnimationMode.LINEAR);
		behaviour = new Clutter.BehaviourPath (alpha, path);
		behaviour.knot_reached.connect ( _on_knot_reached );
		behaviour.apply (this);
	}

	private void _on_knot_reached (Clutter.BehaviourPath path, uint num) {
		debug ("Knot num : %i and path lenght : %i", (int)num, (int)this.path.length);
		if (num == this.path.length - 1) {
			debug ("Final knot.");
			this.path.add_line_to (0, 0);
			this.path.add_close ();
		}
	}

	public void move (Clutter.Stage stage) {
		path.add_move_to ((int)this.x, (int)this.y);
		path.add_line_to ((int)stage.width, (int)stage.height);
		path.add_close ();

		timeline.start ();
	}
}
