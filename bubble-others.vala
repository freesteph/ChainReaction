public class Bubbles.BubbleOther : Bubble {

	private static const double SCALE_FACTOR = 0.4;
	private static const uint SPEED = 10;
	private static const double ANGLE_OFFSET = 0.10;

	//FIXME : public = bad
	public double angle;
	public Clutter.Path path;

	private Clutter.BehaviourPath behaviour_path;
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
		} while ((angle < Math.PI/2 + ANGLE_OFFSET && angle > Math.PI/2 - ANGLE_OFFSET) ||
				 (angle < Math.PI + ANGLE_OFFSET && angle > Math.PI - ANGLE_OFFSET) ||
				 (angle < Math.PI*1.5 + ANGLE_OFFSET && angle > Math.PI*1.5 - ANGLE_OFFSET) ||
				 (angle < ANGLE_OFFSET) ||
				 (angle > Math.PI*2 - ANGLE_OFFSET));

		path = new Clutter.Path ();
		timeline = new Clutter.Timeline (10);
		timeline.completed.connect (_on_timeline_complete);
		timeline.new_frame.connect (_on_new_frame);

		alpha = new Clutter.Alpha.full (timeline, Clutter.AnimationMode.LINEAR);
		behaviour_path = new Clutter.BehaviourPath (alpha, path);
		behaviour_path.apply (this);

		this.set_scale (SCALE_FACTOR, SCALE_FACTOR);
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
		behaviour_path.remove_all ();
	}
}
