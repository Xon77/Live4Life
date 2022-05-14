/*
    GameOfLife WFSCollider - Wave Field Synthesis spatialization for SuperCollider.
    The Game Of Life Foundation. http://gameoflife.nl
    Copyright 2006-2010 Wouter Snoei, Raviv Ganchrow.

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

// copy and modification of "Space" by Raviv

// for help file: type WFS, select it and press command-?


WFSPoint {
	var <>x = 0, <>y = 0, <>z = 0;
	
	*new { arg x=0, y=0, z=0;
		^super.newCopyArgs(x,y,z);
	}
	
	*newAZ { arg a = 0, d = 0, z = 0; // azimuth, distance, z (not included in distance calc)
		var x, y;
		#x,y = WFSTools.singleAZToXY( a,d );
		^super.newCopyArgs(x,y,z);
		}
	
	*newAll { arg array;
		array = array ? [0,0,0];
		^super.new.x_(array.at(0) ? 0).y_(array.at(1) ? 0).z_(array.at(2) ? 0);
	
	}
	
	set { arg argX=0, argY=0, argZ=0; x = argX; y = argY; z = argZ; }
	
	asWFSPoint { ^this } // or WFSSpeaker if this already is one
	
	asArray { ^[x,y,z] }
	
	isWFSPoint { ^true }
	
	couldBeWFSPoint { ^true }
	
	asPoint { ^Point( x,y ) }
	
	//WFSSpeaker support
	
	asWFSSpeaker { |angle = 0| ^WFSSpeaker( x,y,z, angle); }

	isInFrontOf { |aWFSSpeaker| aWFSSpeaker.pointIsInFront( this ); }
	isBehind { |aWFSSpeaker| aWFSSpeaker.pointIsBehind( this ); }
	
	distFromSpeaker { |aWFSSpeaker|
		^aWFSSpeaker.dist( this )  // the absolute distance per speaker
			* aWFSSpeaker.distDirection( this ); 
				// when this is in front of speaker, distance will be negative
			}

	isNextTo { |aWFSSpeaker, round = 0| // or on top of
		var angleOffset;
		if( aWFSSpeaker.class == WFSSpeakerLine )
			{ aWFSSpeaker = aWFSSpeaker.first };
		if( aWFSSpeaker.class == WFSSpeakerArray )
			{ ^aWFSSpeaker.collect({ |item|
				this.isNextTo( item );
				}); }
			{	aWFSSpeaker.asWFSSpeaker;
				angleOffset = aWFSSpeaker.angleOffset( this ).round(round);
				^(angleOffset == 270) or: (angleOffset == 90) 
			};
		}
		
	neg { ^this.class.new( x.neg, y.neg, z.neg ) }
					
	== { arg aWFSPoint; 
		^(x == aWFSPoint.x) and: { y == aWFSPoint.y } and: { z == aWFSPoint.z } }
		
	+ { arg deltaWFSPoint;
		var oldArgs, newArgs; 
		oldArgs = this.storeArgs;
		newArgs = deltaWFSPoint.asWFSPoint.storeArgs.extend( oldArgs.size, 0  );
		^this.class.new( *( oldArgs + newArgs ) )
	}	
	
	- { arg deltaWFSPoint;
		var oldArgs, newArgs; 
		oldArgs = this.storeArgs;
		newArgs = deltaWFSPoint.asWFSPoint.storeArgs.extend( oldArgs.size, 0  );
		^this.class.new( *( oldArgs - newArgs ) )
	}
		
	* { arg scaleWFSPoint;
		var oldArgs, newArgs; 
		oldArgs = this.storeArgs;
		newArgs = scaleWFSPoint.asWFSPoint.storeArgs.extend( oldArgs.size, 1  );
		^this.class.new( *( oldArgs * newArgs ) )
	}
	
	/ { arg scaleWFSPoint;
		var oldArgs, newArgs; 
		oldArgs = this.storeArgs;
		newArgs = scaleWFSPoint.asWFSPoint.storeArgs.extend( oldArgs.size, 1  );
		^this.class.new( *( oldArgs / newArgs ) )
	}
	
	div { arg scaleWFSPoint;
		var oldArgs, newArgs; 
		oldArgs = this.storeArgs;
		newArgs = scaleWFSPoint.asWFSPoint.storeArgs.extend( oldArgs.size, 1  );
		^this.class.new( *( oldArgs div: newArgs ) )
	}
	
	<= { |aWFSPoint| // sort support
		^(x <= aWFSPoint.x) && 
		(y <= aWFSPoint.y) &&
		(z <= aWFSPoint.z)
		 }
	
	move { arg delta;
		delta = delta.asWFSPoint;
		^(this + delta)
	}
	
	moveAZ { arg angle, distance, round=0;
		var delta;
		delta = WFSTools.singleAZToXY(angle, distance);
		^this.move( delta.round(round) );
		}
		
	
	scale { arg scale, center;
		center = center ? WFSPoint(0,0,0);
		center = center.asWFSPoint;
		^((this - center) * scale) + center;
	}
	
	/* 
	rotate { arg angle; // in radians -- not used in wfs
		var sinr, cosr;
		sinr = angle.sin;
		cosr = angle.cos;
		^((x * cosr) + (y * sinr)) @ ((x * sinr) + (y * cosr)) // this is wrong, look it up
	}
	*/

	abs { ^WFSPoint.newAll([this.x, this.y, this.z].abs) }
	
	rho { ^hypot(x, y) } //2D only - distance
	theta { ^atan2(y, x) } //2D only - azimuth - 2pi (watch out: turned a quarter)
	
	dist { arg aWFSPoint;	 //ws - optimized calculation
		aWFSPoint = aWFSPoint.asWFSPoint; 
		^(sqrdif(x, aWFSPoint.x) + sqrdif(y, aWFSPoint.y) + sqrdif(z, aWFSPoint.z) ).sqrt
		}
		
	distOpt { arg aWFSPoint, deltaXSquared, deltaYSquared, deltaZSquared;
	
		 // provided values are not calculated again
		 		
		//aWFSPoint = aWFSPoint.asWFSPoint; 
		
		deltaXSquared = deltaXSquared ?? { sqrdif(x, aWFSPoint.x); };
		deltaYSquared = deltaYSquared ?? { sqrdif(y, aWFSPoint.y); };
		
		// deltaZSquared = deltaZSquared ?? { sqrdif(z, aWFSPoint.z); }; 
		// z = out -> 4% cpu saving
		
		^( deltaXSquared + deltaYSquared ).sqrt;
	
		}
			
	angleFromCenter { //^WFSPoint(0,0,0).angleTo(this);
		^WFSTools.fromRadians( this.radianAngleFrom( WFSPoint(0,0,0) ) );
		}
	
	radianAngleFrom { arg aWFSPoint;
		aWFSPoint = aWFSPoint.asWFSPoint;
		^atan2(x - aWFSPoint.x, y - aWFSPoint.y); 
		}
				
	radianAngleTo { arg aWFSPoint;
		^this.radianAngleFrom( aWFSPoint ) + pi;
		}	
		
	angleTo { arg aWFSPoint;
		^WFSTools.fromRadians( this.radianAngleFrom( aWFSPoint ) + pi ) }
	
	angleFrom { arg aWFSPoint; 
		//^aWFSPoint.asWFSPoint.angleTo( this ); 
		^WFSTools.fromRadians( this.radianAngleFrom( aWFSPoint ) )
		}
		
	angle { ^this.angleTo( 0 ); }  // for use as WFSPlane
	distance { ^this.dist( 0 ); }
		
	distOld { arg aWFSPoint;			//RAVIV NOTE, ONLY CRITTICAL CALCULATION
		aWFSPoint = aWFSPoint.asWFSPoint; 
		^hypot((z - aWFSPoint.z), hypot(x - aWFSPoint.x, y - aWFSPoint.y))
	}
	
	distXY { arg aWFSPoint;  //only xy, not z		
		aWFSPoint = aWFSPoint.asWFSPoint;	
	 	^hypot(x - aWFSPoint.x, y - aWFSPoint.y)
	}
	
	transpose { ^y @ x }
	
	asRect { |otherCorner|
		otherCorner = (otherCorner ? this).asWFSPoint.asPoint;
		^Rect.fromPoints( this.asPoint, otherCorner.asPoint )
		}
	
	*rand { arg radius = 1.0, z = 0; // 2D
		var azimuth, distance;
		distance = radius.rand;
		azimuth = 2pi.rand;
		^(([azimuth.sin, azimuth.cos] * distance) ++ [z]).asWFSPoint;
		}
		
	*rand2 {  arg radiusMin = 0.5, radiusMax = 1.0, z = 0; // 2D
		var azimuth, distance;
		distance = radiusMin + (radiusMax - radiusMin).rand;
		azimuth = 2pi.rand;
		^(([azimuth.sin, azimuth.cos] * distance) ++ [z]).asWFSPoint;
		}
	
	*rand3D { arg min = -1.0, max = 1.0;
		min = min.asWFSPoint;
		max = max.asWFSPoint;
		^WFSPoint( 
			min.x + (max.x - min.x).rand,
			min.y + (max.y - min.y).rand,
			min.z + (max.z - min.z).rand );
			}
		
	
	round { arg quant; 
		quant = quant.asWFSPoint;
		^WFSPoint.newAll([x.round(quant.x), y.round(quant.y), z.round(quant.z)])
	}
	trunc { arg quant; 
		quant = quant.asWFSPoint;
		WFSPoint.newAll([x.trunc(quant.x), y.trunc(quant.y), z.trunc(quant.z)])

	}
	
	blend { |that, blendFrac = 0.5|
		that = that.asWFSPoint;
		^WFSPoint( 
			x.blend(that.x, blendFrac),
			y.blend(that.y, blendFrac),
			z.blend(that.z, blendFrac) );
		}
			
	printOn { arg stream;
		stream << "WFSPoint( " << x << ", " << y << ", " << z << " )";
	}
	
	storeArgs { ^[x,y,z] }
	
	flipX { ^this.class.new( -1 * x, y, z ) }
	flipY { ^this.class.new( x, -1 * y, z ) }
	
	toScreenCoord{ |size, fromRect|
		var point;
		size = size ? 400;	
		
		point = ( WFSPointArray[ this ]).scaleToRect( Rect(0,0,1,1), fromRect )[0].asPoint;
		
		point.y = 1 - point.y;
		
		point = point * size;
		
		^point
		
	}
	
	fromScreenCoord{ |size, toRect|
		var point;
		var factor, newRect;
		
		factor = (1 /toRect.width).min( 1/ toRect.height );
		newRect = Rect(0,0,toRect.width*factor,toRect.height*factor);
		newRect.origin = newRect.centerIn(Rect(0,0,1,1));		
		size = size ? 400;	
		
		point = this / size;
		
		point.y = 1 - point.y;
		
		^( WFSPointArray[ point ]).scaleFromRect( newRect, toRect )[0];
		
	}
	
	plotSmoothInput { |size, color, fromRect| // x/y
		var point;
		color = color ? Color(0.67, 0.84, 0.90, 0.75); // light blue
			
		point = this.toScreenCoord(size, fromRect);
		// points
		color.set;
		
		Pen.addArc( point, 3, 0, 2pi );
		Pen.cross( point, 6, '+' );
		Pen.stroke;
		^point;
		}
		
	plotSmooth { |speakerConf = \default, toFront = true, event|
		
		var window;
		var point, point2;
		var fromRect;
		var toRect, newRect, factor, width, moving = false, mousePos;
		/*
		window = SCWindow("WFSPoint", Rect(128, 64, 400, 400)).front;
		window.view.background_(Color.black );
		*/

		window = WFSPlotSmooth( "WFSPoint", toFront: toFront );
		
		if( speakerConf == \default )
			{ speakerConf = WFSConfiguration.default };
			
		point = this.asPoint;
		
		fromRect = Rect.fromPoints( 0@0, point );
		
		fromRect = fromRect.union( speakerConf.asRect );
		
		toRect = Rect(0,0,window.view.bounds.width,window.view.bounds.height);
		width = toRect.width;
		factor = (toRect.width / fromRect.width).min( toRect.height / fromRect.height );
		newRect = Rect(0,0,fromRect.width*factor,fromRect.height*factor);
		newRect.origin = newRect.centerIn(toRect);
		
		WFSPlotSmooth.view.drawFunc_({ var tempPath, tempPath2, firstPoint, bounds;
			bounds = [window.view.bounds.width, window.view.bounds.height]; 
			bounds = bounds.minItem;
						
			if( speakerConf.notNil )
				{ speakerConf.plotSmoothInput( bounds, fromRect: fromRect ) };

			
			this.plotSmoothInput( bounds, fromRect: fromRect );
			
			if(moving) {
				Pen.font = Font( "Helvetica-Bold", 10 );
				Pen.color = Color.white;
				Pen.stringAtPoint("x: "++this.x.round(0.1)++", y: "++this.y.round(0.1),mousePos + Point(7,0))
			}
			
		})
		.mouseDownAction_({|v, x, y, mod|
			var point;
			
			
			point = WFSPointArray[this].scaleToRect(toRect, fromRect)[0].asPoint;
			point.y = width - point.y;
			if(Rect.fromPoints(point - 	Point(4,4),point + Point(4,4)).containsPoint(x@y)) {
				moving = true;
				mousePos = x@y;
			}
					
		})
		.mouseMoveAction_({|v, x, y, mod|
			var point;
			if(moving) {
				x = x.clip(0,width);
				y = y.clip(0,window.view.bounds.height);
				point = WFSPointArray[WFSPoint(x,window.view.bounds.height-y)].scaleFromRect(newRect, fromRect)[0];
				this.x = point.x;
				this.y = point.y;
				mousePos = x@y;
				v.refresh;
				
			}
			
		})
		.mouseUpAction_({ |v,x,y|
			if( moving ) {
				event.changed;
				moving = false;
				v.refresh
			}	
			
		});
			
			
		window.refresh;
		}
	
	
}





