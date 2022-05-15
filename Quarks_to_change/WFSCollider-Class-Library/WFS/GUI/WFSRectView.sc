/*
    GameOfLife WFSCollider - Wave Field Synthesis spatialization for SuperCollider.
    The Game Of Life Foundation. http://gameoflife.nl
    Copyright 2006-2011 Miguel Negrao, Wouter Snoei.

    GameOfLife WFSCollider software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    GameOfLife WFSCollider is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with GameOfLife WFSCollider.  If not, see <http://www.gnu.org/licenses/>.
*/

//////// PATH EDITOR /////////////////////////////////////////////////////////////////

WFSRectView : WFSBasicEditView {

	defaultObject	{ ^Rect.aboutPoint( 0@0, 5, 5 ) }	
	
	mouseEditSelected { |newPoint, mod|
		var pt;
		// returns true if changed
		if( mod.isKindOf( ModKey ).not ) {
			mod = ModKey( mod ? 0);
		};
		switch( editMode,
			\move,  { 
				pt = (newPoint.round(round) - lastPoint.round(round)) * (1@(-1));
				this.moveSelected( pt.x, pt.y, mod, \no_undo );
			},
			\scale, { 
				pt = [ lastPoint.round(round).abs.max(0.001) * 
						lastPoint.asArray.collect({ |item|
							(item > 0).binaryValue.linlin(0,1,-1,1)
						}).asPoint,
					  newPoint.round(round).abs.max(0.001) * 
						newPoint.asArray.collect({ |item|
							(item > 0).binaryValue.linlin(0,1,-1,1)
						}).asPoint
				]; // prevent inf/nan
				pt = pt[1] / pt[0];
				this.scaleSelected( pt.x, pt.y, mod, \no_undo ); 
			},
			\rotate, { 
				this.rotateSelected( 
					lastPoint.angle - newPoint.angle, 
					1,
					mod, 
					\no_undo
				);
			},
			\rotateS, { 
				this.rotateSelected( 
					lastPoint.theta - newPoint.theta, 
					newPoint.rho.max(0.001) / lastPoint.rho.max(0.001), 
					mod,
					\no_undo
				);
			}
		);
	}
	
	
	drawContents { |scale = 1|
		var points;
		var selectColor = Color.yellow;
		
		scale = scale.asArray.mean;
		
		Pen.use({	
			
			Pen.width = 0.164;
			Pen.color = Color.red(0.5, 0.5);
				
			//// draw configuration
			(WFSSpeakerConf.default ?? {
				WFSSpeakerConf.rect(48,48,5,5);
			}).draw;
				
			// draw center
			Pen.line( -0.25 @ 0, 0.25 @ 0 ).line( 0 @ -0.25, 0 @ 0.25).stroke;
			
			Pen.scale( 1, -1 );
			
			Pen.width = scale;
			
			points = this.getPoints;
			
			Pen.color = Color.blue(0.5,0.25);
			Pen.moveTo( points.first );
			points[..3].reverse.do({ |item|
					Pen.lineTo( item );	
			});
			Pen.fill;
			
			Pen.color = Color.blue(0.5,0.75);
			points.do({ |item|
					Pen.moveTo( item );
					Pen.addArc( item, 3 * scale, 0, 2pi );
			});
			Pen.stroke;
			
			// selected
			Pen.use({	
				if( selected.notNil ) {	
					Pen.width = scale;
					Pen.color = selectColor;
					selected.do({ |item|
						Pen.moveTo( points[item] );
						Pen.addArc( points[item] , 2.5 * scale, 0, 2pi );
					});
					
					Pen.fill;
				};
			});
			
						
		});
		
	}
	
	getPoints { ^object.corners ++ [ object.center ]; }
	
	getNearestIndex { |point, scaler| // returns nil if outside radius
		var radius;
		radius = scaler.asArray.mean * 5;
		^this.getPoints.detectIndex({ |pt, i|
			pt.asPoint.dist( point ) <= radius
		});
	}
	
	getIndicesInRect { |rect|
		var pts = [];
		this.getPoints.do({ |pt, i|
			if( rect.contains( pt.asPoint ) ) { pts = pts.add(i) };
		});
		^pts;					
	}
	
	// general methods
	
	resize { ^view.resize }
	resize_ { |resize| view.resize = resize }
	
	rect_ { |rect| this.object = rect.asRect }
	rect { ^object }
	
	// changing the object
	
	moveSelected { |x = 0,y = 0, mod ...moreArgs|
		var points;
		if( selected.size > 0 ) {
			points = this.getPoints.deepCopy;
			selected.do({ |index|
				var pt, which;
				which = #[ leftTop, rightTop, rightBottom, leftBottom, center ][ index ];
				pt = points[index];
				pt.x = pt.x + x;
				pt.y = pt.y + y;
				object = object.perform( which.asSetter, pt );
			});
			object.positiveExtent;
			
			this.refresh; 
			this.edited( \edit, \move, *moreArgs );
		};
	}
	
	scaleSelected { |x = 1, y, mod ...moreArgs|
		y = y ? x;
		if( selected.size > 0 ) {
			selected.do({ |index|
				var pt, which;
				which = #[ 
					[ left, top ], 
					[ right, top ],
					[ right, bottom ],
					[ left, bottom ],
				][ index ];
				pt = object.perform( which[0] ) @ object.perform( which[1] );
				pt.x = pt.x * x;
				pt.y = pt.y * y;
				object.perform( which[0].asSetter, pt.x );
				object.perform( which[1].asSetter, pt.y );
			});
			this.refresh;
			this.edited( \edit, \scale, *moreArgs );
		};
	}
	
	rotateSelected { |angle = 0, scale = 1, mod ...moreArgs|
		if( selected.size > 0 ) {
			selected.do({ |index|
				var pt, rpt, which;
				which = #[ 
					[ left, top ], 
					[ right, top ],
					[ right, bottom ],
					[ left, bottom ],
				][ index ];
				pt = object.perform( which[0] ) @ object.perform( which[1] );
				rpt = pt.rotate( angle ) * scale;
				pt.x = rpt.x;
				pt.y = rpt.y;
				object.perform( which[0].asSetter, pt.x );
				object.perform( which[1].asSetter, pt.y );
			});
			
			this.refresh;
			this.edited( \edit, \rotate, *moreArgs );
		};
	}
	
	// selection
	
	select { |...indices|
		if( indices[0] === \all ) { 
			indices = object.corners.collect({ |item, i| i }).flat; 
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
			index = object.corners.collect({ |item, i| i }).flat 
		} {
			index = index.flat.select(_.notNil);
		};
		if( selected != index ) {
			selected = index;
			this.changed( \select ); 
		};
	}

}
