+ Integer {
	numDigits {
		var number = this.abs, digits = 1;
		while { (number = number / 10) > 1 } { digits = digits + 1 };
		^digits;
	}

	pairsDo { |func|
		if (this < 1) { "Integer::pairsDo requires the receiver to be positive.".error };
		(1, 3 .. this).do { |i| func.(i, i + 1) };
	}

	doAdjacentPairs { |func|
		if (this < 1) { "Integer::overlapPairsDo requires the receiver to be positive.".error };
		(1 .. this).do { |i| func.(i, i + 1) };
	}

	linspace { |a, b| ^(a, ((b - a) / (this - 1)) + a .. b) }

	envspace { |a, b, env| ^this.linspace(a, b).collect(env[_]) }
}