WFSPathTransformerDef( \duration, 
	{ |f, path|
		var tms, origTms, seldur, dur, adddur;
		var sel;
		sel = f.selection;
		if( sel.size > 0 ) {
			origTms = path.times;
			tms = origTms.clipAt(sel);
			seldur = tms.sum;
			dur = path.times.sum;
			adddur = f.get( \duration ) - dur;
			tms = (tms.normalizeSum * (seldur + adddur)).max(0.001);
			tms.do({ |tm, i|
				origTms[ sel[i] ] = tm;
			});
			path.times = origTms;
		};
		path.times = path.times.normalizeSum * f.get( \duration );
	},
	[ \duration, 1 ],
	{ |f, path| [ \duration, path.duration ] }
	)
	.setSpec( \duration, SMPTESpec(0.001) )
	.useSelection_( false );