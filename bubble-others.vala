public class Bubbles.BubbleOther : Bubble {

	private double angle;

	private Clutter.Path path;
	private Clutter.BehaviourPath behaviour;
	private Clutter.Alpha alpha;
	private Clutter.Timeline timeline;

	/* FIXME : not so cool to have a bunch of random color. Maybe ~30
	   color are enough. */
	public BubbleOther (Clutter.Stage s, Clutter.Color color) {
		base (s, color);
		do {
			angle = Random.double_range (0, 2*Math.PI);
			/* We random it again if it's too close to right angles */
		} while ((angle < Math.PI/2 + 0.10 && angle > Math.PI/2 - 0.10) ||
				 (angle < Math.PI + 0.10 && angle > Math.PI - 0.10) ||
				 (angle < Math.PI*1.5 + 0.10 && angle > Math.PI*1.5 - 0.10) ||
				 (angle < 0.10) ||
				 (angle > Math.PI*2 - 0.10));

		path = new Clutter.Path ();

		timeline = new Clutter.Timeline (0);
		timeline.completed.connect (_on_timeline_complete);
		timeline.new_frame.connect (_on_new_frame);

		alpha = new Clutter.Alpha.full (timeline, Clutter.AnimationMode.LINEAR);
		behaviour = new Clutter.BehaviourPath (alpha, path);
		behaviour.apply (this);
		
		this.set_scale (0.4, 0.4);
	}

	private void _on_new_frame (Clutter.Timeline time, int msecs) {
		if (Board.freeze) {
			this.expand ();
			timeline.pause ();
		}
	}

	private void _on_timeline_complete (Clutter.Timeline time) {
			var newx = (int)this.x;
			var newy = (int)this.y;

			this.path.clear ();
			this.path.add_move_to (newx, newy);
			var dest = calculate_path ();
			debug ("The next point NOW is %i, %i", dest.x, dest.y);
			this.path.add_line_to (dest.x, dest.y);
			timeline.duration = this.path.length * 7;
			timeline.start ();
	}

	private Clutter.Knot calculate_path () {
		Clutter.Knot destination = { 0, 0 };
		double dx, dy;
		double opposite;
		double x = this.x;
		double y = this.y;
		double w = stage.width;
		double h = stage.height;
		double angle = this.angle;
		bool horizontal_hit = false;

		if (angle < Math.PI/2) {
			/* We're going up-right */
			opposite = Math.tan (angle) * (w - x);
			if (y - opposite < 0) {
				/* we're hitting the top */
				horizontal_hit = true;
				opposite = Math.tan (Math.PI/2 - angle) * y;
				dx = x + opposite;
				dy = 0;
			} else {
				/* we're hitting the right edge */
				dx = w;
				dy = y - opposite;
			}
		} else if (angle < Math.PI) {
			/* up-left */
			opposite = Math.tan (angle - Math.PI/2) * y;
			if (x - opposite < 0) {
				/* right hit */
				opposite = Math.tan (Math.PI - angle) * x;
				dx = 0;
				dy = y - opposite;
			} else {
				/* top hit */
				horizontal_hit = true;
				dy = 0;
				dx = x - opposite;
			}
		} else if (angle < Math.PI*1.5) {
			/* down-left */
			opposite = Math.tan (angle - Math.PI) * x;
			if (y + opposite > h) {
				/* bottom hit */
				horizontal_hit = true;
				opposite = Math.tan (Math.PI*1.5 - angle) * (h - x);
				dx = x - opposite;
				dy = h;
			} else {
				/* right hit */
				dx = 0;
				dy = y + opposite;
			}
		} else {
			/* down-right */
			opposite = Math.tan (angle - Math.PI*1.5) * (h - y);
			if (x + opposite > w) {
				/* left hit */
				opposite = Math.tan (Math.PI*2 - angle) * (h - x);
				dx = w;
				dy = y + opposite;
			} else {
				/* bottom hit */
				horizontal_hit = true;
				dx = x + opposite;
				dy = h;
			}
		}

		if (horizontal_hit) {
			angle = Math.PI*2 - angle;
		} else {
			angle = Math.PI - angle;
			if (angle < 0) (angle += Math.PI*2);
		}

		this.angle = angle;
//		assert (dx >= 0 && dx <= w);
//		assert (dy >= 0 && dy <= h);
		destination.x = (int) dx;
		destination.y = (int) dy;
		return destination;
	}

	public void move () {
		path.clear ();
		path.add_move_to ((int)this.x, (int)this.y);
		debug ("The first angle is : %g", this.angle);
		var dest = calculate_path ();
		path.add_line_to (dest.x, dest.y);
		timeline.duration = path.length * 6;
		timeline.start ();
	}
}
