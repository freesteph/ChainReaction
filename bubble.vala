
public abstract class Bubble : Clutter.CairoTexture {

	private static const short RADIUS = 30;
	private static const short EXPAND_TIME = 200;
	private static const short OPACITY = 200;

	private Cairo.Context cr;
	// FIXME : not nice to store a ClutterStage in every bubble.
	protected Clutter.Stage stage;

	private Clutter.BehaviourScale behaviour_scale;
	private Clutter.Alpha alphascale;
	private Clutter.Timeline timescale;

	public Bubble (Clutter.Stage s, Clutter.Color color) {
		stage = s;
		
		this.set_anchor_point_from_gravity (Clutter.Gravity.CENTER);
		this.set_surface_size (RADIUS*2, RADIUS*2);
		this.opacity = OPACITY;
		//FIXME : would it be better to use the opacity in the color ?

		cr = this.create ();
		Clutter.cairo_set_source_color (cr, color);
		cr.arc (RADIUS, RADIUS, RADIUS, 0, Math.PI*2);
		cr.fill ();
		cr = null;

		timescale = new Clutter.Timeline (EXPAND_TIME);
		alphascale = new Clutter.Alpha.full (timescale, Clutter.AnimationMode.LINEAR);
		behaviour_scale = new Clutter.BehaviourScale (alphascale, 0, 0, 1, 1);
		behaviour_scale.apply (this);
	}
		
	public void expand () {
		timescale.start ();
	}
}