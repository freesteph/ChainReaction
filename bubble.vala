
public abstract class Bubble : Clutter.CairoTexture {

	/* TODO : implement fadout */
	public static const short RADIUS = 30;
	private static const short EXPAND_TIME = 300;
	private static const short OPACITY = 200;
	private static const short IDLE_TIME = 2500;

	private Cairo.Context cr;

	private Clutter.BehaviourScale behaviour_scale;
	private Clutter.Alpha alphascale;
	private Clutter.Timeline scale_time;
	private Clutter.Timeline idle_time;

	public signal void end_fadeout (Bubble b);

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

		scale_time = new Clutter.Timeline (EXPAND_TIME);
		alphascale = new Clutter.Alpha.full (scale_time, Clutter.AnimationMode.EASE_OUT_BACK);
		behaviour_scale = new Clutter.BehaviourScale (alphascale, 0, 0, 1, 1);
		behaviour_scale.apply (this);

		idle_time = new Clutter.Timeline (IDLE_TIME);
		idle_time.completed.connect ( () =>
			{
				fadeout ();
			});

	}
		
	public void expand () {
		behaviour_scale.set_bounds (this.scale_x, this.scale_y, 1, 1);
		scale_time.start ();
		scale_time.completed.connect ( () =>
			{
				idle_time.start ();
			});
		// FIXME : I don't like lamba methods all over
	}

	public void fadeout () {
		behaviour_scale.set_bounds (0, 0, 1, 1);
		scale_time.direction = Clutter.TimelineDirection.BACKWARD;
		scale_time.start ();
		scale_time.completed.connect ( () =>
			{
				end_fadeout (this);
			});
	}

	public void reset () {
		this.set_scale (1, 1);
		scale_time.stop ();
	}
}