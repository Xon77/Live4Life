(
// create some Udefs

Udef( \mix2, { |balance = 0.5| // mix two inputs together
	var l1, l2;
	l1 = UIn.ar( 0 ) * (1-balance);
	l2 = UIn.ar( 1 ) * balance;
	UOut.ar( 0, l1 + l2 )
} );

Udef( \vibrato, { |rate = 1, amount = #[0.0,1.0]| // a tremolo/vibrato
	UOut.ar( 0, SinOsc.kr( rate ).range(*amount) * UIn.ar( 0 ) )
} );

)

// \sine and \output are already in the Udef bank

x = UChain( \sine, [ \sine, [ \freq, 550, \u_o_ar_0_bus, 1 ]], \mix2, \vibrato, \wfsSource );

x.prepareAndStart;
x.release;

x.fadeOut = 0.5;
x.fadeIn = 0.5;

x.duration_( 5 );
x.duration_( inf ); // infinite duration (default)

// change audio outputs
x[0].setAudioOut( 0, 0 );
x[1].setAudioOut( 0, 1 ); // 2nd sine output to bus 1, so it goes to second mix input

x.gui; 
