+ SimpleNumber {
	/* THESE ARE ALL BROKEN :( */
	
	// eq { |... values|
	// 	values.doAdjacentPairs { |a, b| if (a != b) { ^false } };
	// 	^true;
	// }

	// lt { |... values|
	// 	values.doAdjacentPairs { |a, b| if (a >= b) { ^false } };
	// 	^true;
	// }

	// ltEq { |... values|
	// 	values.doAdjacentPairs { |a, b| if (a > b) { ^false } };
	// 	^true;
	// }

	// gt { |... values|
	// 	values.doAdjacentPairs { |a, b| if (a <= b) { ^false } };
	// 	^true;
	// }

	// gtEq { |... values|
	// 	values.doAdjacentPairs { |a, b| if (a < b) { ^false } };
	// 	^true;
	// }

	toRadians { ^this * pi / 180 }

	toDegrees { ^this * 180 / pi }

	asBoolean { |value = 1| ^if (this == value) { true } { false } }
}