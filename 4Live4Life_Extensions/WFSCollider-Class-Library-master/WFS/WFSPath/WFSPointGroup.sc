/*
    GameOfLife WFSCollider - Wave Field Synthesis spatialization for SuperCollider.
    The Game Of Life Foundation. http://gameoflife.nl
    Copyright 2006-2013 Wouter Snoei.

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

WFSPointGroup {
	var <positions;
	
	*new { |positions|
		^super.newCopyArgs( positions ).init;
	}
	
	*generate { |size = 20 ...args|
		var editors, pointGroup;
		if( args.size == 0 ) { args = [ \circle ] };
		editors = args.collect(_.asWFSPathGenerator); // use pathgenerators for now
		pointGroup = this.new( {0@0}!size );
		editors.do({ |ed|
			if( ed.def.changesT.not ) {
				pointGroup = ed.applyFunc( pointGroup );
			} {
				"%:% - % cannot be used for generating a %\n".postf(
					this.class, thisMethod.name, ed, this );
			};
		});
		^pointGroup;
	}
	
	init {
		this.changed( \init );
	}
	
	positions_ { |pos| 
		positions = pos.as( Array ).collect(_.asPoint); // make sure it is valid
		this.changed( \positions );
	}
	
	times_ { "%:times_ - a WFSPointGroup can not store time data\n".postf( this.class ); }
	times { ^1!positions.size }
	
	// methods from old WFSPath
	x { ^positions.collect(_.x) }
	y { ^positions.collect(_.y) }
	
	distances { ^positions[1..].collect({ |pt, i| pt.dist( positions[i] );  }) } // between points

	left { ^this.x.minItem } 
	back { ^this.y.minItem } // is top
	right { ^this.x.maxItem } 
	front { ^this.y.maxItem } // is bottom
	width { ^this.right - this.left }
	depth { ^this.front - this.back }
	
	asRect { ^Rect( this.left, this.back, this.width, this.depth ) }
	
	size { ^positions.size }
	
	at { |index| ^positions[ index ] }
	
	copySelection { |indices | // indices should not be out of range!
		var pos, tim;
		indices = indices ?? { (..positions.size-1) };
		pos = positions[ indices ].collect(_.copy);
		^this.class.new( pos );
	}
	
	putSelection { |indices, selectionPointGroup| // in place operation !!
		selectionPointGroup = selectionPointGroup.asWFSPointGroup; 
		indices = indices ?? { (..selectionPointGroup.positions.size-1) };
		indices.do({ |item, i|
			positions.put( item, selectionPointGroup.positions[i].copy );
		});
		this.changed( \positions );
	}
	
	insertPoint { |index = 0, point|
		point = point.asPoint;
		this.positions = positions.insert( index, point );
	}
	
	insertMultiple { |index = 0, points|
		points = points.asCollection.collect(_.asPoint);
		this.positions = positions[..index-1] ++ points ++ positions[index..];
		^index + (..points.size-1); // return indices of selection
	}
	
	== { |that|
		if (that.class != this.class) { ^false };
		^(positions == that.positions)
	}
	
	asWFSPointGroup { ^this }
	isWFSPointGroup { ^true }
	
	asWFSPath2 { ^WFSPath2( positions.deepCopy ) }
	
	asControlInput { ^positions.collect(_.asArray).flat }
	asOSCArgEmbeddedArray { | array| ^this.asControlInput.asOSCArgEmbeddedArray(array) }
	
	archiveAsCompileString { ^true }
	
	storeArgs { ^[ positions ] }
}

+ Object { 
	isWFSPointGroup { ^false }
}

+ WFSPath2 {
	asWFSPointGroup {
		^WFSPointGroup( this.positions.collect(_.asPoint) );
	}
}

+ Collection {
	asWFSPointGroup {
		^WFSPointGroup( this.collectAs(_.asPoint, Array) );
	}
}

+ Symbol {
	asWFSPointGroup { |size = 20|
		^WFSPointGroup.generate( size, this );
	}
}

+ Nil {
	asWFSPointGroup { 
		^WFSPointGroup( { |i| Polar( 8, i.linlin(0,15,0,2pi) ).asPoint  } ! 15 );
	}
}

+ WFSPath_Old {
	asWFSPointGroup {
		^WFSPointGroup( this.positions.collect(_.asPoint) );
	}
}