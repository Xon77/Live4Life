(
c = WFSSpeakerConf.default ? WFSSpeakerConf.rect( 48, 48, 5, 5 );
m = \lines;
a = \point;
p = (0@0);
w = ScaledUserView.window( "WFSSpeakerConf", 
	Rect( 128, 64, 400, 400 ), 
	Rect.aboutPoint( 0@0, 20, 20 );
);
w.keepRatio = true;
w.drawFunc = { 
	var fader, crossfades, lines, focusMul = 1;
	c.draw(m); 
	Pen.addArc( p * (1 @ -1), 0.3/2, 0, 2pi ).fill; 
	if( a == \point ) { focusMul = c.focusDetector.kr( p ); };
	// draw corns as blue points
	Pen.color = Color.blue;
	c.arrayConfs.collect(_.cornerPoints).do({ |pts|
		pts.do({ |p|
			Pen.addArc( p * (1 @ -1), 0.164/2, 0, 2pi ).fill; 
		});
	});
	
	// draw normal as blue lines behind arrays
	if( a === \point ) {
		fader = WFSCrossfader( p, c.arrayConfs, focusWidth: c.focusWidth );
		crossfades = fader.cornerfades;
		lines = c.asLines;
		Pen.use({
			Pen.scale(1.1, -1.1);
			Pen.width = 0.2;
			fader.arraysShouldRun( false ).do({ |fade, i|
				if( fade == 1 ) {
					Pen.color = Color.blue.alpha_( crossfades[i] );
					Pen.line( *lines[i] ).stroke;
				};
			});
		});
		
		// draw focused as blue lines inside arrays
		if( focusMul == 1 ) {
			Pen.use({	
				
				Pen.scale(0.9, -0.9);
				Pen.color = Color.blue;
				Pen.width = 0.2;
				fader.arraysShouldRun( true ).do({ |fade, i|
					if( fade == 1 ) {
						Pen.line( *lines[i] ).stroke;
					};
				});
			});
		};
	} {
		fader = WFSCrossfaderPlane(p, c.arrayConfs );
		crossfades = fader.crossfades;
		lines = c.asLines;
		Pen.use({
			Pen.scale(1.1, -1.1);
			Pen.width = 0.2;
			lines.do({ |line, i|
				Pen.color = Color.blue.alpha_( crossfades[i] );
				Pen.line( *lines[i] ).stroke;		
			});
		});

	};
	

};
w.scale = 2;
w.mouseDownAction = { |v, x,y| p = (x @ y.neg); };
w.mouseMoveAction = { |v, x,y| p = (x @ y.neg); };
	);


c = WFSSpeakerConf.rect( 40, 56, 6, 4 ); w.refresh; // rectangular setup
c = WFSSpeakerConf.rect( 48, 48, 5, 5 ); w.refresh;
c = WFSSpeakerConf.polygon(6, 6, 192); w.refresh; // 192 speaker polygon (32 sp per side)
c = WFSSpeakerConf.polygon(5, 5, 160); w.refresh; // pentagon
c = WFSSpeakerConf.polygon(3, 3.5, 192); w.refresh; // triangle
c = WFSSpeakerConf.polygon(4, 3, 192); w.refresh; // overlapping (still works)

( // also works with incomplete conf (like on a single server)
c = WFSSpeakerConf.polygon(4, 5, 192);
c.arrayConfs.removeAt(3);
c.arrayConfs.removeAt(2);
w.refresh; 
)

//switch to plane
a = \plane;

// problems with determining focus:
c = WFSSpeakerConf.polygon(24, 6, 192); w.refresh;
c = WFSSpeakerConf.polygon(8, 5, 192 ); w.refresh;
(
c = WFSSpeakerConf.polygon(8, 5, 192 );
c[[0,2,4,6]].do(_.n_(40)).do(_.dist_(5));
c[[1,3,5,7]].do(_.n_(8)).do(_.dist_(6)); 
c.init;
w.refresh;
)

// other problems:
c = WFSSpeakerConf.polygon(2, 4.5, 192); w.refresh;

m = \points; w.refresh; // change plot mode
m = \lines; w.refresh;

c[0].offset = 1; w.refresh; // move first array to left
c[0].offset = 0; w.refresh; 

c[0].cornerAngles[1]/pi;

c[1].angle = 0.025pi; c.init; w.refresh; // change angle of second array
c[2].angle = -0.49pi; c.init; w.refresh; // change angle of second array
c[3].angle = -1.025pi; c.init; w.refresh;