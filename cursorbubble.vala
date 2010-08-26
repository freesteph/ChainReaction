public class Bubbles.CursorBubble : Clutter.CairoTexture {

	private Cairo.Context cr;
	private Clutter.Stage stage;

	private Clutter.BehaviourScale behaviour;
	private Clutter.Alpha alpha;
	private Clutter.Timeline timeline;

	public CursorBubble (Clutter.Stage s) {
		stage = s;
		this.set_anchor_point_from_gravity (Clutter.Gravity.CENTER);

		this.set_surface_size (Main.BUBBLE_RADIUS_EXPANDED*2,
							   Main.BUBBLE_RADIUS_EXPANDED*2);
		cr = this.create ();
		Clutter.cairo_set_source_color (cr, { 0, 0, 0, 200 });
		cr.arc (Main.BUBBLE_RADIUS_EXPANDED, Main.BUBBLE_RADIUS_EXPANDED,
				Main.BUBBLE_RADIUS_EXPANDED, 0, Math.PI*2);
		cr.fill ();
		cr = null;

		timeline = new Clutter.Timeline (200);
		alpha = new Clutter.Alpha.full (timeline, Clutter.AnimationMode.LINEAR);
		behaviour = new Clutter.BehaviourScale (alpha, 0, 0, 1, 1);
		behaviour.apply (this);

	}
}
