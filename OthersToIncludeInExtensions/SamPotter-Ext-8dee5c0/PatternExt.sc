+ Pattern {
	envspace { |n, lo, hi, env|
		// env.dur
		var indices = List[];
		var delta = hi - lo;
		if (lo == 0) {
			n.do { |i| this.copy.do { |j| indices.add((i * delta) + j) } };
		} {
			n.do { |i| this.copy.do { |j| indices.add((i * delta) - lo + j) } };
		};
		^env[(indices * env.dur / n).sort];
	}
} 