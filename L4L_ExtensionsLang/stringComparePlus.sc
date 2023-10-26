// adapted from http://sourcefrog.net/projects/natsort/strnatcmp.c
// by Martin Pool

+ String {

	compareRight{ |string|
		var bias = 0, a, b;

		/* The longest run of digits wins.  That aside, the greatest
		value wins, but we can't know that it will until we've scanned
		both numbers to know that they have the same magnitude, so we
		remember it in BIAS. */
		inf.do({|i|
			a = this[i];
			b = string[i];
			if ((a.isNil or: {a.isDecDigit.not})  &&  (b.isNil or: {b.isDecDigit.not}), {^bias});
			if (a.isNil or: {a.isDecDigit.not}, {^-1});
			if (b.isNil or: {b.isDecDigit.not}, {^1});
			if (a < b, {
				if (bias == 0, { bias = -1 });
			}, {
				if (a > b, {
					if (bias == 0, { bias = 1 },{
						if (a.isNil  &&  b.isNil, {^bias});
					});
				});
			});
		});
		^0;
	}

	compareLeft { |string|
		var a, b;
		/* Compare two left-aligned numbers: the first to have a
		different value wins. */
		inf.do({|i|
			a = this[i];
			b = string[i];
			if((a.isNil or: {a.isDecDigit.not})  &&  (b.isNil or: {b.isDecDigit.not}), {^0});
			if(a.isNil or: {a.isDecDigit.not}, {^-1});

			if(b.isNil or: {b.isDecDigit.not}, {^1});

			if(a < b, {^-1});

			if(a > b, {^1});

		});

		^0;
	}

	naturalCompare { |string, ignoreCase = false|
		var ai, bi; // int
		var ca, cb; // nat_char
		var fractional, result; // int

		ai = bi = 0;
		while(true, {
			ca = this[ai]; cb = string[bi];

			/* skip over leading spaces or zeros */
			while ({ca.notNil and: {ca.isSpace}}, {ca = this[ai = ai + 1]});

			while ({cb.notNil and: {cb.isSpace}}, {cb = string[bi = bi + 1]});

			if (ca.isNil && cb.isNil, {^0});
			/* The strings compare the same.  Perhaps the caller
			will want to call strcmp to break the tie. */

			/* process run of digits */
			if (ca.notNil && cb.notNil and: {ca.isDecDigit  &&  cb.isDecDigit}, {
				fractional = (ca == $0 || cb == $0);

				if (fractional, {
					if((result = this.copyToEnd(ai).compareLeft(string.copyToEnd(bi))) != 0, {
						^result
					});
				}, {
					if((result = this.copyToEnd(ai).compareRight(string.copyToEnd(bi))) != 0, {
						^result
					});
				});
			});

			if (ignoreCase, {
				ca = ca.toUpper;
				cb = cb.toUpper;
			});

			if (ca < cb, {^-1});
			if (ca > cb, {^1});

			ai = ai + 1; bi = bi + 1;
		});
	}

	naturalCompareWithSpaces { |string, ignoreCase = false|
		var ai, bi; // int
		var ca, cb; // nat_char
		var fractional, result; // int

		ai = bi = 0;
		while(true, {
			ca = this[ai]; cb = string[bi];

			/* skip over leading spaces or zeros */
			/*while ({ca.notNil and: {ca.isSpace}}, {ca = this[ai = ai + 1]});

			while ({cb.notNil and: {cb.isSpace}}, {cb = string[bi = bi + 1]});

			if (ca.isNil && cb.isNil, {^0});*/

			/* The strings compare the same.  Perhaps the caller
			will want to call strcmp to break the tie. */

			/* process run of digits */
			if (ca.notNil && cb.notNil and: {ca.isDecDigit  &&  cb.isDecDigit}, {
				fractional = (ca == $0 || cb == $0);

				if (fractional, {
					if((result = this.copyToEnd(ai).compareLeft(string.copyToEnd(bi))) != 0, {
						^result
					});
				}, {
					if((result = this.copyToEnd(ai).compareRight(string.copyToEnd(bi))) != 0, {
						^result
					});
				});
			});

			if (ignoreCase, {
				ca = ca.toUpper;
				cb = cb.toUpper;
			});

			if (ca < cb, {^-1});
			if (ca > cb, {^1});

			ai = ai + 1; bi = bi + 1;
		});
	}

	// Test pour essayer que 2.WAV soit placé après 2#1.WAV dans dossier PianoCagedRusted -> comment avoir le même classement que dans le Finder OSX ?????????
	naturalCompareWithSpaces2 { |string, ignoreCase = false|
		var ai, bi; // int
		var ca, cb; // nat_char
		var fractional, result; // int

		ai = bi = 0;
		while(true, {
			ca = this[ai]; cb = string[bi];

			/* skip over leading spaces or zeros */
			/*while ({ca.notNil and: {ca.isSpace}}, {ca = this[ai = ai + 1]});

			while ({cb.notNil and: {cb.isSpace}}, {cb = string[bi = bi + 1]});

			if (ca.isNil && cb.isNil, {^0});*/
			/* The strings compare the same.  Perhaps the caller
			will want to call strcmp to break the tie. */

			/* process run of digits */
			if (ca.notNil && cb.notNil and: {ca.isDecDigit  &&  cb.isDecDigit}, {
				fractional = (ca == $0 || cb == $0);

				if (fractional, {
					if((result = this.copyToEnd(ai).compareLeft(string.copyToEnd(bi))) != 0, {
						^result
					});
				}, {
					if((result = this.copyToEnd(ai).compareRight(string.copyToEnd(bi))) != 0, {
						^result
					});
				});
			});

			if (ignoreCase, {
				ca = ca.toUpper;
				cb = cb.toUpper;
			});

			if (ca < cb, {^-1});
			if (ca > cb, {^1});

			/*if (ca.isNil and: cb.notNil, {^-1});
			if (ca.notNil and: cb.isNil, {^1});*/
			if (ca.size < cb.size, {^-1});
			if (ca.size > cb.size, {^1});

			ai = ai + 1; bi = bi + 1;
		});
	}

}