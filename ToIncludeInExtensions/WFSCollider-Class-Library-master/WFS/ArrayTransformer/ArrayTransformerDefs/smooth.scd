ArrayTransformerDef( \smooth, 
	{ |f, obj| 
		var newPos, win, n, amt, mode;
		n = (f.get( \window ) * obj.size).max(3).round(2);
		amt = f.get( \smooth );
		mode = (f.get( \mode ).asString ++ "At").asSymbol;
		win = ({ |i| 
			i.linlin(0,(n-1).max(2),-0.5pi,1.5pi).sin.linlin(-1,1,0,1) 
		}!n.max(2)).normalizeSum;
		obj.blend( obj.collect({ |item, i|
			var out, sum;	
			out = obj.perform( mode, (i + (n/ -2).ceil .. i + (n/2).ceil - 1) ) * win;
			sum = 0;
			out.do({ |item| sum = sum + item; }); 
			sum;
		}), amt );
	}, 
	[ \smooth, 0, \window, 0.3, \mode, \clip ],
	{ |f, path| [ \smooth, 0, \window, f.get( \window ),  \mode, f.get( \mode ) ] }
)
	.setSpec( \smooth, ControlSpec( -1, 1, \lin, 0, 0 ) )
	.setSpec( \window, ControlSpec( 0, 1, \lin, 0.0, 0.3 ) )
	.setSpec( \mode, ListSpec( [ \clip, \wrap, \fold ] ) )
	.useSelection_( false );