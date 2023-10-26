+ SequenceableCollection {
	dropFirst { if (this.size > 0) { this.removeAt(0) } }

	dropLast { if (this.size > 0) { this.removeAt(this.lastIndex) } }

	removeFirst { ^if (this.size > 0) { this.removeAt(0) } }

	removeLast { ^if (this.size > 0) { this.removeAt(this.lastIndex) } }

	head { ^this.at(0) }

	tail { ^this[1 .. this.size - 1] }

	second { ^this.at(1) }

	third { ^this.at(2) }

	fourth { ^this.at(3) }

	fifth { ^this.at(4) }

	sixth { ^this.at(5) }

	seventh { ^this.at(6) }

	eighth { ^this.at(7) }

	ninth { ^this.at(8) }

	tenth { ^this.at(9) }

	exclusiveClump { |groupSize|
		var clumped = this.clump(groupSize);
		^if (clumped.last.size != clumped.first.size) {
			clumped[0 .. clumped.size - 2];
		} {
			clumped;
		};
	}

	asDictionary {
		var tmp = Dictionary[];
		this.pairsDo { |key, val| tmp[key] = val };
		^tmp;
	}

	asIdentityDictionary {
		//		var check = [];
		var tmp = IdentityDictionary[];
		//		this.pairsDo { |key| check.add(key) };
		//		if (check.size > check.asSet.size) { "Duplicate keys.".error };

		/* also need to check for non-symbol keys*/
		this.pairsDo { |key, val| tmp[key] = val };
		^tmp;
	}

	asEvent {
		//		var check = [];
		var tmp = ();
		//		this.pairsDo { |key| check.add(key) };
		//		if (check.size > check.asSet.size) { "Duplicate keys.".error };

		/* check for non-symbol-non-string keys */
		this.pairsDo { |key, val| tmp[key] = val };
		^tmp;
	}

	clumpDo { |n, func|
		if (this.size / 3 != 0) {
			"Sequence to clump's size must be a multiple of n.".error;
		};
		this.clump(n).do { |i| func.(*i) };
	}

	eq { ^this[0].eq(*this[1 .. this.size - 2]) }

	lt { ^this[0].lt(*this[1 .. this.size - 2]) }
	
	ltEq { ^this[0].ltEq(*this[1 .. this.size - 2]) }

	gt { ^this[0].gt(*this[1 .. this.size - 2]) }

	gtEq { ^this[0].gtEq(*this[1 .. this.size - 2]) }

	asEnv { |dur = 1| ^Env(this, (dur / (this.size - 1)) ! (this.size - 1), 0) }
}