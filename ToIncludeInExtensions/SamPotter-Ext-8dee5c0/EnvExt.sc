+ Env {
	*flat { |amp = 1, dur = 1| ^this.new(amp ! 2, [dur]) }

	*line { |start, end, dur| ^this.new([start, end], [dur]) }

	*saw2 { |segs = 64, amp = 1, startPhase = 0, endPhase = 2pi, dur = 1|
		var phaseInc = startPhase + ((endPhase - startPhase) / segs);
		^Env.new(
			(startPhase, phaseInc .. endPhase).collect { |phase|
				amp * (2 * ((phase / pi) - floor((phase / pi) + 0.5)));
			},
			(segs.reciprocal ! segs) * dur
		);
	}

	*square2 { |segs = 64, amp = 1, startPhase = 0, endPhase = 2pi, dur = 1|
		var phaseInc = startPhase + ((endPhase - startPhase) / segs);
		^Env.new(
			(startPhase, phaseInc .. endPhase).collect { |phase|
				amp * sign(phase.sin);
			},
			(segs.reciprocal ! segs) * dur
		);
	}

	*sine2 { |segs = 64, amp = 1, startPhase = 0, endPhase = 2pi, dur = 1|
		var phaseInc = startPhase + ((endPhase - startPhase) / segs);
		^Env.new(
			(startPhase, phaseInc .. endPhase).collect { |phase|
				amp * phase.sin;
			},
			(segs.reciprocal ! segs) * dur
		);
	}

	*triangle2 { |segs = 64, amp = 1, startPhase = 0, endPhase = 2pi, dur = 1|
		var phaseInc = startPhase + ((endPhase - startPhase) / segs);
		^Env.new(
			(startPhase, phaseInc .. endPhase).collect { |phase|
				  amp
				* (2 / pi)
				* (phase - (pi * floor((phase / pi) + 0.5)))
				* (1.neg ** floor((phase / pi) - 0.5));
			},
			(segs.reciprocal ! segs) * dur
		);
	}

	levelsCollect { |function|
		var temp = levels.collect { |level, index| function.(level, index) };
		^this.deepCopy.levels_(temp);
	}

	timesCollect { |function|
		var temp = times.collect { |level, index| function.(level, index) };
		^this.deepCopy.times_(temp);
	}

	curvesCollect { |function|
		var temp = switch(curves.class,
			Array, { curves.collect { |level, index| function.(level, index) } },
			{ this.segments.collect { |level, index| function.(level, index) } }
		);
		^this.deepCopy.curves_(temp);
	}

	segments { ^times.size }

	nodes { ^levels.size }

	normalizeTimes { |duration = 1| this.times_(times.normalizeSum * duration) }

	normalizeLevels { |low = 0, high = 1|
		this.levels_(levels.collect(_.linlin(
			levels.sort.first, levels.sort.last, low, high)));
	}

	dur { ^times.sum }

	++ { |env| ^this.concat(env) }

	concat { |env|
		^Env.new(
			levels.putLast((levels.last + env.levels.first) / 2) ++
			env.levels.reject { |item, index| index == 0 },
			times ++ env.times,
			if (curves.isKindOf(Collection)) { curves } { curves ! times.size } ++
			if (env.curves.isKindOf(Collection)) { env.curves } {
				env.curves ! env.times.size });
	}
	
	concatfade {
		^Env.new(
			[-1] ++ levels,
			[0.1] ++ times,
			[0] ++ if (curves.isKindOf(Collection)) { curves } { curves ! times.size });
	}
	
	blentSignal { |env, samples, blend|
		^this.asSignal(samples).blend(env.asSignal(samples), blend);
	}

	blentSignals { |env, samples(2 ** 14), interpPoints = 3, blend(Env.line(0, 1, 1)),
			inclusive = true|
		var signals = List.new, b, blendIndex;
		(if (inclusive) { interpPoints + 2 } { interpPoints }).do { |index|
			blendIndex = index + if (inclusive) { 0 } { 1 } / (interpPoints + 1);
			b = case { blend.isKindOf(Function) } {
				blend.(blendIndex);
			} { blend.isMemberOf(Env) or: blend.isMemberOf(Tendency) } {
				blend.at(blendIndex);
			} {
				"Invalid blend type.".warn;
				^nil;
			};
			signals.add(this.blentSignal(env, samples, b));
		};
		^signals.asArray;
	}

	// some sort of bug here... fix it
	*blentTerrain { |envs, samples(2 ** 14), interpPoints = 3, blends|
		var terrain = List.new, segments = envs.size - 1, blendIndex;
		blends = blends ? Env.new([0.0, 1.0], [1.0]);
		
		case { interpPoints.isKindOf(Collection) && (interpPoints.size != segments) } {
			"interpPoints is not the correct size. Must equal envs.size - 1.".warn;
			^nil;
		} { blends.isKindOf(Collection) && (blends.size != segments) } {
			"blends is not the correct size. Must equal envs.size - 1.".warn;
			^nil;
		};

		if (interpPoints.isKindOf(Number) or: interpPoints.isKindOf(Function)
			or: interpPoints.isMemberOf(Tendency))
			{ interpPoints = [interpPoints].wrapExtend(segments) };
		if (blends.isKindOf(Number) or: blends.isKindOf(Function)
			or: blends.isMemberOf(Tendency))
			{ blends = [blends].wrapExtend(segments) };

		segments.do { |segmentIndex|
			terrain.add(envs.at(segmentIndex).asSignal(samples));
			terrain.addAll(envs.at(segmentIndex).getBlentSignals(
				envs.at(segmentIndex + 1), samples, interpPoints.at(segmentIndex),
				blends.at(segmentIndex), false));
		};
		^terrain.add(envs.last.asSignal(samples)).asArray;
	}

	interpArray { |style = \recursive, depth_min = 0, depth_max = 3, scale = 1|
		^switch (style.asSymbol) { \recursive } {
			(depth_min .. depth_max).collect { |depth|
				this.recursiveInterp(depth, scale) };
		} { \fractal } {
			(depth_min .. depth_max).collect { |depth|
				this.fractalInterp(depth, scale) };
		} { \stochastic } {
			"Stochastic interpolation not yet implemented.".warn;
		};
	}

	recursiveInterp { |depth = 1, scale = 1|
		var new_env, interp;

		interp = { |env, scale|
			var new_levels, new_times, new_curves, max_level;
			#new_times, new_levels = { List.new } ! 2;
			
			new_curves = if (env.curves.isKindOf(Collection)) 
				{ env.curves.wrapExtend(env.segments.squared) } 
				{ env.curves };
			env.times.normalizeSum.do { |time|
				new_times.addAll(env.times.normalizeSum * time) };
			
			(0 .. env.levels.size - 2).do { |i|
				var delta = env.levels[i + 1] - env.levels[i];
				new_levels.add(env.levels[i]);
				(1 .. env.levels.size - 2).do { |j|
					var scale_value = case
					{ scale.isKindOf(Number) } { scale }
					{ scale.isMemberOf(Function) } { scale.(j / (env.levels.size - 1)) }
					{ scale.isMemberOf(Env) } {	scale.at(j / (env.levels.size - 1)) }
					{ 1 };
					new_levels.add(env.levels[i] + (delta * (j / (env.levels.size - 1))) +
						(scale_value * env.levels[j]));
				};
			};
			
			new_levels.add(env.levels.last);

			max_level = new_levels.abs.sort.last;
			if (max_level > 1) {
				new_levels = new_levels.collect(_ * max_level.reciprocal) };
			
			Env.new(new_levels.asArray, new_times.asArray, new_curves);
		};
		
		case { depth < 0 } {
			"Depth must be a value greater than or equal to 0.".warn;
			^nil;
		} { depth == 0 } {
			^this;
		} { levels.first != levels.last } {
			"First and last levels must be equal to recursively interpolate.".warn;
			^nil;
		} {
			new_env = interp.(this, scale);
			if (depth > 1) { (depth - 1).do { new_env = interp.(new_env, scale) } };
			^new_env;
		};
	}

	fractalInterp { |depth = 1, scale = 1|
		var new_env, interp;

		interp = { |env, scale|
			var new_levels = List.new, new_times, new_curves, max_level;

			(0 .. env.levels.size - 2).do { |i|
				var delta = env.levels.at(i + 1) - env.levels.at(i);
				new_levels.add(env.levels.at(i));
				(1 .. levels.size - 2).do { |j|
					var scale_value = case
					{ scale.isKindOf(Number) } { scale }
					{ scale.isMemberOf(Function) } { scale.(j / (env.levels.size - 1)) }
					{ scale.isMemberOf(Env) } {	scale.at(j / (env.levels.size - 1)) }
					{ 1 };
					new_levels.add(
						env.levels.at(i) + (delta * (j / (levels.size - 1))) +
						(env.levels.at(j) * scale_value));
				};
			};
			
			new_levels.add(env.levels.last);

			max_level = new_levels.abs.sort.last;
			if (max_level > 1) {
				new_levels = new_levels.collect(_ * max_level.reciprocal) };

			new_times = times.wrapExtend(new_levels.size - 1).normalizeSum;
				
			new_curves = if (curves.isKindOf(Collection)) {
				curves.wrapExtend(new_levels.size - 1);
			} {
				curves;
			};
						
			Env.new(new_levels.asArray, new_times, new_curves);
		};

		case { depth < 0 } {
			"Depth must be a value greater than or equal to 0.".warn;
			^nil;
		} { depth == 0 } {
			^this;
		} { levels.first != levels.last } {
			"First and last levels be equal to recursively interpolate.".warn;
			^nil;
		} {
			new_env = interp.(this, scale);
			if (depth > 1) { (depth - 1).do { new_env = interp.(new_env, scale) } };
			^new_env;
		};
	}
}