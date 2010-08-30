
public abstract class Bubble : Clutter.CairoTexture {

	/* TODO : implement fadout */
	public static const short RADIUS = 30;
	private static const short EXPAND_TIME = 200;
	private static const short OPACITY = 200;
	private static const uint FADOUT_TIME = 2000;

	private Cairo.Context cr;

	private Clutter.BehaviourScale behaviour_scale;
	private Clutter.Alpha alphascale;
	private Clutter.Timeline timescale;
	private Clutter.Timeline fadeout_time;

	public signal void end_expansion (Bubble b);

	public Bubble (Clutter.Color color) {
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

		fadeout_time = new Clutter.Timeline (FADOUT_TIME);
		fadeout_time.completed.connect ( () =>
			{
				end_expansion (this);
			});

	}
		
	public void expand () {
		behaviour_scale.set_bounds (this.scale_x, this.scale_y, 1, 1);
		timescale.start ();
		fadeout_time.start ();
	}

	public void fadeout () {
		behaviour_scale.set_bounds (0, 0, 1, 1);
		timescale.direction = Clutter.TimelineDirection.BACKWARD;
		timescale.start ();
	}
}