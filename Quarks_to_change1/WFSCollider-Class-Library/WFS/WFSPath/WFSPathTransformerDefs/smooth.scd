WFSPathTransformerDef( \smooth, 
	{ |f, path| 
		var newPos, win, n, amt;
		n = (f.get( \window ) * path.positions.size).max(3);
		amt = f.get( \smooth );
		win = ({ |i| 
			i.linlin(0,(n-1).max(2),-0.5pi,1.5pi).sin.linlin(-1,1,0,1) 
		}!n.max(2)).normalizeSum;
		newPos = path.positions.collect({ |item, i|
			var out, sum;	
			out = path.positions.modeAt(
				(i + (n/ -2).ceil .. i + (n/2).ceil - 1), path.clipMode ) * win;
			sum = 0@0;
			out.do({ |item| sum = sum + item; }); 
			sum;
		});
 			
		path.positions_( 
			path.positions.collect({ |item, i| item.blend( newPos[i], amt ) })
		);
	}, 
	[ \smooth, 0, \window, 0.3 ],
	{ |f, path| [ \smooth, 0, \window, f.get( \window) ] }
)
	.setSpec( \smooth, ControlSpec( -1, 1, \lin, 0, 0 ) )
	.setSpec( \window, ControlSpec( 0, 1, \lin, 0.1, 0.3 ) )
	.useSelection_( false );