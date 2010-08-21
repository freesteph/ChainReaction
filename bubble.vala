public class Bubbles.Bubble : Clutter.CairoTexture {

	private Cairo.Context cr;
	private double angle;

	private Clutter.Stage stage;
	/* FIXME : I'm not sure it's very nice to store a ClutterStage
	   in each bubble. Every function using the stage should be moved
	   to the Board instead. */
	private Clutter.Path path;
	private Clutter.BehaviourPath behaviour;
	private Clutter.Alpha alpha;
	private Clutter.Timeline timeline;

	/* FIXME : not so cool to have a bunch of random color. Maybe ~30
	   color are enough. */
	public Bubble (Clutter.Color color, Clutter.Stage s) {
		stage = s;
		angle = Random.double_range (0, 2*Math.PI);
		this.set_anchor_point_from_gravity (Clutter.Gravity.CENTER);
		this.set_surface_size (Main.BUBBLE_RADIUS*2, Main.BUBBLE_RADIUS*2);

		cr = this.create ();
		Clutter.cairo_set_source_color (cr, color);
		cr.arc (Main.BUBBLE_RADIUS, Main.BUBBLE_RADIUS, Main.BUBBLE_RADIUS, 0, Math.PI*2);

		cr.fill ();
		cr = null;

		path = new Clutter.Path ();

		timeline = new Clutter.Timeline (1000);
		timeline.loop = true;

		alpha = new Clutter.Alpha.full (timeline, Clutter.AnimationMode.LINEAR);
		behaviour = new Clutter.BehaviourPath (alpha, path);
		behaviour.knot_reached.connect ( _on_knot_reached );
		behaviour.apply (this);
	}

	private void _on_knot_reached (Clutter.BehaviourPath bpath, uint num) {
		if (num == this.path.get_n_nodes () - 1) {
			double opposite;
			if (this.angle < Math.PI/2) {
				/* We're going up-right */
				opposite = this.x + Math.sin (this.angle) * this.y;
				if (opposite > stage.width) {
					opposite = Math.sin (this.angle) * (stage.width - this.x);
					this.path.add_line_to ((int)stage.width, (int)(this.x - opposite));
				} else {
					this.path.add_line_to (0, (int)(this.x + opposite));
				}
			} else if (this.angle < Math.PI) {
				/* up-left */
				opposite = this.x - Math.sin (this.angle - Math.PI/2) * this.y;
				if (opposite < 0) {
					opposite = this.y - Math.sin (Math.PI - this.angle) * (this.x);
					this.path.add_line_to (0, (int)opposite);
				} else {
					this.path.add_line_to ((int)opposite, 0);
				}
			} else if (this.angle < Math.PI * 1.5) {
				/* down-left */
				opposite = this.x - Math.sin (Math.PI*1.5 - this.angle) * (stage.height - this.y);
				if (opposite < 0) {
					opposite = this.y + Math.sin (this.angle - Math.PI) * this.x;
					this.path.add_line_to (0, (int)opposite);
				} else {
					this.path.add_line_to ((int)stage.height, (int)opposite);
				}
			} else {
				/* down-right */
				opposite = this.y + Math.sin (2*Math.PI - this.angle) * (stage.width - this.x);
				if (opposite > stage.height) {
					opposite = this.x + Math.sin (this.angle - Math.PI*1.5) * (stage.height - this.y);
					this.path.add_line_to ((int)stage.height, (int)opposite);
				} else {
					this.path.add_line_to ((int)stage.width, (int)opposite);
				}
			}
			timeline.duration *= 2;
			this.angle = Math.fabs (Math.PI - this.angle);
		}
	}

	public void move () {
		path.add_move_to ((int)this.x, (int)this.y);
		path.add_line_to (0, (int)stage.width);
		timeline.start ();
	}
}
