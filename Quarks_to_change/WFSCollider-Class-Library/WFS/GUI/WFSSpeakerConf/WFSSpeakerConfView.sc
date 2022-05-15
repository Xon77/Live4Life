WFSSpeakerConfView : WFSBasicEditView {
	
	var <>showCorners = true;
	
	defaultObject	{ ^nil } // nil means default
	
	conf { ^object ? WFSSpeakerConf.default; }
	
	conf_ { |newConf| 
		object.removeDependant( this );
		this.object = newConf ? WFSSpeakerConf.default; 
		object.addDependant( this );
	}
	
	init {
		this.conf = this.conf;
		this.onClose = { this.conf.removeDependant( this ); };
	}
	
	update { { this.refresh }.defer }
	
	drawContents { |scale = 1|
		var conf, lines;
		var count = 0;
		var letters;
		
		scale = scale.asArray.mean;
	
		
		conf = this.conf;
		
		if( conf.notNil ) {
			Pen.use({
				// show selection
				Pen.scale(1,-1);
				lines = conf.asLines;
				
				if( selected.size > 0 ) {
					
					Pen.width = 0.164 * 2;
					Pen.color = Color.yellow;
					
					lines.do({ |line, i|
						if( selected.includes( i ) ) {
							Pen.line( *line );
						};
					});
					Pen.stroke;
					
				};
				
				Pen.color = Color.black;
				
				letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
				
				conf.arrayConfs.do({ |arrayConf, i|
					var points, counts, movePt;
					points = [ arrayConf.lastPoint, arrayConf.firstPoint ];
					counts = count + [0, arrayConf.n-1 ];
					count = count + arrayConf.n;
					movePt = Polar(12, arrayConf.angle.neg ).asPoint;
					
					Pen.color = Color.black.alpha_(0.33);
					Pen.font = Font( Font.defaultSansFace, 9 );
					points.do({ |item, ii|
						Pen.use({
							Pen.translate( item.x, item.y );
							Pen.scale(scale,scale.neg);
							Pen.stringCenteredIn( 
								counts[ii].asString,
								Rect.aboutPoint( movePt, 20, 15)
							);
						});
					});
					
					Pen.color = Color.red(0.5, 0.5);
					Pen.font = Font( Font.defaultSansFace, 14 );
					Pen.use({
						Pen.translate( *(arrayConf.centerPoint).asArray );
						Pen.scale(scale,scale.neg);
						Pen.stringCenteredIn( 
								letters[i].asString,
								Rect.aboutPoint( movePt, 22, 22)
							);
						
					});
					
					if( showCorners ) {
						Pen.color = Color.black.alpha_(0.33);
						arrayConf.cornerPoints.do({ |pt|
							Pen.addArc( pt, scale * 2.5, 0, 2pi );
						});
						Pen.fill;
					};
					
				});
				
			});
			
			Pen.use({
				
				Pen.width = 0.164;
				Pen.color = Color.red(0.5, 0.5);
					
				//// draw configuration
				conf.draw;
				
			});
				
			Pen.use({
				var rect, arrayConf, pts, gap, leftTop;
				Pen.font = Font( Font.defaultSansFace, 10 );
				Pen.color = Color.black;
				leftTop = this.view.viewRect.leftTop;
				Pen.translate( leftTop.x, leftTop.y );
				Pen.scale(*scale.dup);
				case { conf.arrayConfs.size == 1 } {
					Pen.stringAtPoint( 
						"single array: % speakers, dist: %m, angle: %pi, width: %m"
							.format( 
								conf.arrayConfs[0].n,
								conf.arrayConfs[0].dist.asStringWithFrac(2),
								(conf.arrayConfs[0].angle / pi).asStringWithFrac(2),
								conf.arrayConfs[0].n * conf.arrayConfs[0].spWidth
							),
						5@2
					);
				} { selected.size == 1 or: { conf.arrayConfs.size == 1 } } {
					arrayConf = conf.arrayConfs[ selected[0] ];
					if( arrayConf.notNil ) {
						Pen.stringAtPoint( 
							"array %: % speakers, dist: %m, angle: %pi, width: %m"
								.format( 
									letters[selected[0]],
									arrayConf.n,
									arrayConf.dist.asStringWithFrac(2),
									(arrayConf.angle / pi).asStringWithFrac(2),
									arrayConf.n * arrayConf.spWidth
								),
							5@2
						);
					};
				} { selected.size == 0 } {
					rect = conf.asRect;
					Pen.stringAtPoint( 
						"% speakers, % arrays, dimensions: %m x %m"
							.format( 
								conf.arrayConfs.collect(_.n).sum, 
								conf.arrayConfs.size,
								rect.width.asStringWithFrac(2),
								rect.height.asStringWithFrac(2),
							),
						5@2
					);
				} { selected.size == 2 } {
					pts = conf.arrayConfs[selected]
						.collect({ |arr| [ arr.firstPoint, arr.lastPoint ] });
					gap = [ 
						pts[0][0].dist(pts[1][0]), 
						pts[0][1].dist(pts[1][1]), 
						pts[0][0].dist(pts[1][1]), 
						pts[0][1].dist(pts[1][0]),
					].minItem;
					Pen.stringAtPoint( 
						"arrays %: % speakers, gap: %m"
							.format( 
								selected.collect(letters[_]).join( ", "), 
								conf.arrayConfs[selected].collect(_.n).sum,
								gap.asStringWithFrac(2)
							),
						5@2
					);
				} {
					Pen.stringAtPoint( 
						"arrays %: % speakers"
							.format( 
								selected.collect(letters[_]).join( ", "), 
								conf.arrayConfs[selected].collect(_.n).sum
							),
						5@2
					);
				};
			});
			
		};
		
	}
	
	select { |...indices|
		if( indices[0] === \all ) { 
			indices = object.positions.collect({ |item, i| i }).flat; 
		} { 
			indices = indices.flat.select(_.notNil);
		};
		if( selected != indices ) {
			selected = indices; 
			this.refresh;
			this.changed( \select );
		};
	}
	
	selectNoUpdate { |...index|
		if( index[0] === \all ) { 
			index = object.positions.collect({ |item, i| i }).flat 
		} {
			index = index.flat.select(_.notNil);
		};
		if( selected != index ) {
			selected = index;
			this.changed( \select ); 
		};
	}

	
	zoomToFit {
		view.viewRect_( 
			(this.conf).asRect.scale(1@(-1)).insetBy(-1,-1) 
		);  
	}
	
	getNearestIndex { |point, scaler| // returns nil if outside radius
		var radius;
		var conf;
		conf = this.conf;
		if( conf.notNil ) {
			radius = scaler.asArray.mean * 5;
			^conf.arrayConfs.detectIndex({ |arr, i|
				var pt;
				pt = point.rotate( arr.angle.neg );
				pt.x.inclusivelyBetween( arr.dist - radius, arr.dist + radius ) &&
				{
					pt.y.inclusivelyBetween( 
						arr.rotatedFirstPoint.y - radius,
						arr.rotatedLastPoint.y + radius
					);
				};
			});
		} {
			^nil;
		};
	}
	
	
	getIndicesInRect { |rect|
		var conf, index = [], corners;
		conf = this.conf;
		if( conf.notNil ) {
			conf.arrayConfs.do({ |arrayConf, i|
				var rct;
				// close enough for jazz..
				rct = Rect.fromPoints( arrayConf.firstPoint, arrayConf.lastPoint );
				if( rct.intersects( rect ) ) { index = index.add(i) };
			});
		};
		^index;			
	}
	
	mouseEditSelected {
	}
	
	moveSelected { }

}