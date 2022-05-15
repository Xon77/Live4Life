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

+ WFSPath2 {
	
	draw { |drawMode = 0, selected, pos, showControls = false, pixelScale = 1|
		
		var curves;
		var selectColor = Color.yellow;
		var pospt, times;
		var points, controls, scale;
		
		selected = selected ? [];
		
		// drawMode 0: points+lines, 1: lines, 2: points, 3: none, 4: hi-res lines
		
		scale = pixelScale.asArray.mean;
		
		Pen.use({

			// draw contents
			Pen.scale( 1, -1 );	
					
			//// this
			points = this.positions.collect(_.asPoint);
			controls = if( this.respondsTo( \controls ) )
					{ this.controls }
					{ points.collect({ |item, i|
							points.clipAt( (i-1..i+2) ).collect(_.asArray).flop
								.collect({ |array|
								array.splineIntControls(1/3)
							}).flop.collect( _.asPoint);
						});	
					};
					
			curves = points.collect({ |item,i| [ item ] ++ controls[i] });
						
			// controls
			
			if( showControls ) {	
				Pen.color = Color.gray(0.35);
				Pen.width = scale * 0.25;
				
				points[1..].do({ |item, i|
					Pen.line( points[i], controls[i][0] );
					Pen.line( item, controls[i][1] );
					Pen.stroke;
					Pen.addArc( controls[i][0], 1.5 * scale, 0, 2pi );
					Pen.addArc( controls[i][1], 1.5 * scale, 0, 2pi );
					Pen.fill;
				});
			};
			
			
			// lines
			if( [0,1].includes( drawMode ) ) {
				Pen.width = scale * 0.5;
				Pen.color = Color.gray(0.25);
				Pen.moveTo( curves[0][0] );
				curves[1..].do({ |item, i|
					Pen.curveTo( item[0], *curves[i][1..] );
				});
				Pen.stroke;
			};
			
			// points
			if( [0,2,4].includes( drawMode ) ) {	
				Pen.width = scale;
				Pen.strokeColor = Color.black.alpha_(0.5); 
				Pen.fillColor = Color.white; // start point
				Pen.moveTo( curves[0][0] );
				Pen.addArc( curves[0][0], 4 * scale, 0, 2pi );
				Pen.fillStroke;
				
				Pen.fillColor = Color.red(0.95); // end point
				Pen.moveTo( curves.last[0] );
				Pen.addArc( curves.last[0], 4 * scale, 0, 2pi );
				Pen.fillStroke;
			};
			
			if( drawMode == 4 ) {	
				times = this.times / this.times.mean;
				Pen.color = Color.gray(0.25);
				curves[1..].do({ |item, i|
					var n, pt1;
					n = times[i] * 10;
					pt1 = [ curves[i][0], item[0] ].splineIntPart1( *curves[i][1..] );
					n.do({ |ii|
						Pen.addArc( pt1.splineIntPart2( ii / n ), scale, 0, 2pi );
					});
				});
				Pen.fill;
			};
			
			// selected
			Pen.use({	
				if( selected.notNil ) {	
					Pen.width = scale * 2;
					Pen.color = selectColor;
					selected.do({ |item|
						if( item < curves.size ) {
							Pen.moveTo( curves[item][0] );
							Pen.addArc( curves[item][0] , 4 * scale, 0, 2pi );
						};
					});
					
					Pen.fill;
				};
			});
			
			// show position
			if( pos.notNil ) {
				pospt = this.atTime( pos ).asPoint;
				Pen.color = Color.black.alpha_(0.5);
				Pen.moveTo( pospt );
				Pen.addArc( pospt , 5 * scale, 0, 2pi );
				Pen.fill;
			};
			
			if( [0,2,4].includes( drawMode ) ) {	
				Pen.color = Color.blue(1,0.5);
				curves[1..curves.size-2].do({ |item|
					Pen.moveTo( item[0] );
					Pen.addArc( item[0], 3 * scale, 0, 2pi );
				});
				Pen.stroke;
			};
		});
		
	}
	
}

+ WFSMultiPath {
	
	draw { |drawMode = 0, selected, pos, showControls = false, pixelScale = 1|
		var indexCount = 0, selections;
		selections = Order();
		
		selected.do({ |item|
			var pathIndex, index;
			#pathIndex, index = this.prPathIndex( item );
			selections[ pathIndex ] = selections[ pathIndex ].add( index );
		});
		
		// selections.dopostln;
		
		paths.do({ |path, i|
			path.draw( drawMode, selections[i], pos, showControls, pixelScale );
		});
	}
}
