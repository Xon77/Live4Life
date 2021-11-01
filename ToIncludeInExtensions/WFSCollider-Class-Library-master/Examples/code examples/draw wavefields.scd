(
c = WFSSpeakerConf.default ?? { WFSSpeakerConf.rect( 48, 48, 5, 5 ); };
m = \lines;
a = \point;
p = 0@7.5; // position
t = 5/344; // time
l = 0@2; // listener position (optional)
d = 0; // latencyComp
~win = Window("WFS preview", Rect(200,200,600,620)).front;
~win.addFlowLayout(0@0,0@0);
w = ScaledUserView.withSliders(~win,  
	Rect( 128, 64, 600, 600 ), 
	Rect.aboutPoint( 0@0, 20, 20 );
).resize_(5);
SmoothSlider(~win, Rect(100,100,600,20))
	.action_{ |v|
		t = v.value.linlin(0.0, 1.0, -10.0/344 , 10/344); w.refresh;
	}
	.centered_(true)
	.value_( 0.75 )
	.resize_(8);
	
w.keepRatio = true;

w.mouseDownAction = { |vw, x, y|
	p = x @ y.neg;
};
w.mouseMoveAction = { |vw, x, y|
	p = x @ y.neg;
};

(
w.drawFunc = { 
	var speakerLines, speakerPoints, prePan, crossfader, crossfades, arrayPan;
	var focusMul = 1;
	var corners, polar, p1, p2, clip = true;
	var showWaveFronts = true, showListener = false;
	c.draw(m);
	corners = c.uniqueCorners;
	focusMul = c.focusDetector.kr( p );
	
	Pen.use({ 
		Pen.scale( 1, -1 );
		Pen.addArc( p, 0.164, 0, 2pi ).fill;
		
		Pen.width = 0.075;
		Pen.line( 0.2@0, -0.2@0 ).line( 0 @ 0.2, 0 @ -0.2 ).stroke;
		
		Pen.color = Color.red(0.5).alpha_(0.25); 
		if( a === \point ) {
			Pen.addArc( p, t.max(0)*344, 0, 2pi ).stroke;
		} {
			polar = p.asPolar;
			polar.rho_( polar.rho - (t*344) );
			p1 = polar.asPoint;
			p2 = Polar( 10, polar.angle-0.5pi).asPoint;
			Pen.line( p1 + p2, p1 - p2 ).stroke;
		};
		
		if( clip && { corners.size > 2 } ) {
			Pen.moveTo( corners.last );
			corners.do({ |pt, i|
				Pen.lineTo( pt );
			});
			Pen.clip;
		};
		
		speakerLines = c.arrayConfs;
		speakerPoints = speakerLines.collect(_.asPoints).collect(_.reverse);
		prePan = WFSPrePan( latencyComp: d).ar( 1, p )[0];
		
		if( a === \point ) {
			crossfader = WFSCrossfader( p, speakerLines, focusWidth: c.focusWidth );
			crossfades = (crossfader.cornerfades * crossfader.arraysShouldRun( false ))
				.max( crossfader.arraysShouldRun( true ) * focusMul );
			arrayPan = speakerLines.collect({ |line|
				WFSArrayPan( *line.asArray ).focusWidth_( c.focusWidth ).focus_(nil).ar( 1, p ) + [-0.06 + prePan,0];
			});
		} {	
			crossfades = WFSCrossfaderPlane( p, speakerLines ).crossfades;
			arrayPan = speakerLines.collect({ |line|
				WFSArrayPanPlane( *line.asArray ).ar( 1, p ) + [-0.06 + prePan,0];
			});
		};
		
		if( showWaveFronts ) {	
			arrayPan.collect({ |times, i|
				var color, amp, delay;
				color = Color.blue(0.5).alpha_(crossfades[i]);
				times = times.flop.flop;
				speakerPoints[i].do({ |sp, ii|
					amp = times[1][ii];
					delay = ((t - times[0][ii] )*344).max(0);
					if( (amp > 0) && { delay > 0 }) {
						Pen.color = color.copy.alpha_( (color.alpha * times[1][ii]).sqrt);
						Pen.addArc( sp, delay, 
							speakerLines[i].angle+0.5pi, pi ).stroke;
					};
				});
			});
		};
		
		if( showListener ) { // draws a head of a listener at actual size
			Pen.fillColor = Color.white;
			Pen.strokeColor = Color.black;
			Pen.width = 1/50;
			Pen.addArc( l, 0.2/2, 0.6pi, 1.8pi );
			Pen.line( Polar(0.2/2, 0.6pi).asPoint + l, l + (0@0.125) );
			Pen.lineTo( Polar(0.2/2, 0.4pi).asPoint + l);
			Pen.fillStroke;
			Pen.addArc( l + ((0.2/2)@0), 0.025, 0, 2pi );
			Pen.addArc(l - ((0.2/2)@0), 0.025, 0, 2pi );
			Pen.fillStroke;
		};
		
	});
};
);

w.scale = 2;
);

// different settings
c = WFSSpeakerConf.rect( 40, 56, 6, 4 ); w.refresh; // rectangular setup
c = WFSSpeakerConf.polygon( 6, 5, 192 ); w.refresh;

( // single array setup
c = WFSSpeakerConf( [ 64, 5, 0.5pi, 0, 0.164 ] ); 
WFSArrayPan.useFocusFades = false;
WFSArrayPan.tapering = 0.1;
w.refresh;
)

( // default setup (Game Of Life, 192sp)
c = WFSSpeakerConf.rect( 48, 48, 5, 5 );
WFSArrayPan.useFocusFades = true; // (for closed setups)
WFSArrayPan.tapering = 0;
w.refresh;
)

m = \points; w.refresh; // change plot mode
m = \none; w.refresh; // hide speakers
m = \lines; w.refresh;

a = \point; w.refresh; // show point
a = \plane; w.refresh; // show plane

// change time
t = -5/344; w.refresh;
t = 0/344; w.refresh;
t = 5/344; w.refresh;
t = 10/344; w.refresh;

// change latencyComp
d = 1; w.refresh;
d = 0; w.refresh;

// animate time
(
{
	var start = 0, end = 10, dur = 8;
	(dur/0.05).do({ |i|
		t = i.linlin(0,(dur/0.05).floor-1,start,end)/344;
		{ w.refresh }.defer;
		0.05.wait;
	});
}.fork;
)

// animate position
(
r = {
	var speed = 1/10;
	inf.do({ |i|
		p = p.rotate( speed * 0.05 * 2pi );
		{ w.refresh }.defer;
		0.05.wait;
	});
}.fork;
)

r.stop; // end animation

c[0].offset = 1; w.refresh; // move first array to left
c[0].offset = 0; w.refresh; 

c[1].angle = 0.05pi; c.init; w.refresh; // change angle of second array
c[1].angle = 0; c.init; w.refresh; 