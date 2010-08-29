public class Bubbles.BubbleOther : Bubble {

	private static const double SCALE_FACTOR = 0.4;
	private static const uint SPEED = 10;

	//FIXME : public = bad
	public double angle;
	public Clutter.Path path;

	private Clutter.BehaviourPath behaviour;
	private Clutter.Alpha alpha;
	private Clutter.Timeline timeline;

	public signal void path_complete (BubbleOther b);
	public signal void new_position (BubbleOther b);
	/* FIXME : not so cool to have a bunch of random color. Maybe ~30
	   color are enough. */
	public BubbleOther (Clutter.Color color) {
		base (color);
		do {
			angle = Random.double_range (0, 2*Math.PI);
			/* We random it again if it's too close to right angles */
			//FIXME : constant
		} while ((angle < Math.PI/2 + 0.10 && angle > Math.PI/2 - 0.10) ||
				 (angle < Math.PI + 0.10 && angle > Math.PI - 0.10) ||
				 (angle < Math.PI*1.5 + 0.10 && angle > Math.PI*1.5 - 0.10) ||
				 (angle < 0.10) ||
				 (angle > Math.PI*2 - 0.10));

		path = new Clutter.Path ();

		timeline = new Clutter.Timeline (10);
		timeline.completed.connect (_on_timeline_complete);
		timeline.new_frame.connect (_on_new_frame);

		alpha = new Clutter.Alpha.full (timeline, Clutter.AnimationMode.LINEAR);
		behaviour = new Clutter.BehaviourPath (alpha, path);
		behaviour.apply (this);

		this.set_scale_with_gravity (SCALE_FACTOR, SCALE_FACTOR, Clutter.Gravity.CENTER);
	}

	private void _on_new_frame (Clutter.Timeline time, int msecs) {
		new_position (this);
	}

	private void _on_timeline_complete (Clutter.Timeline time) {
		path_complete (this);
	}

	public void move () {
		timeline.duration = path.length * SPEED;
		timeline.start ();
	}

	public void stop () {
		timeline.pause ();
	}
}
