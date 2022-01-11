/*
    GameOfLife WFSCollider - Wave Field Synthesis spatialization for SuperCollider.
    The Game Of Life Foundation. http://gameoflife.nl
    Copyright 2006-2010 Wouter Snoei.

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

+ Object {
	isWFSPoint { ^false }
	asWFSPoint { ^nil }
	asWFSSpeaker { ^nil }
	isWFSSpeaker { ^false }
	isWFSPath { ^false }
	asWFSPath { ^nil }
	couldBeWFSPoint { ^false }
	
	}

+ Collection {
	asWFSPoint { ^WFSPoint(*this) }
	asWFSSpeaker { ^WFSSpeaker(*this) }
	asWFSPath { ^WFSPath_Old( this.collect( _.asWFSPoint ) ) }
	asWFSPointArray { ^WFSPointArray.with( *this ) }
	asWFSPathArray { ^WFSPathArray.with(*this) }
	asWFSSpeakerArray { ^WFSSpeakerArray.with(*this) }
	asWFSSpeakerLine { ^WFSSpeakerLine.with(*this) }
	
	couldBeWFSPoint { ^(this.size < 4) && { this.every( { |item|
											item.size == 0 } ) }; 
				}
			
		
	writeWFSFile { |path = "~/scwork/wfsPathsOut.xml", name="example"|
		var array;
		array = this.asWFSPathArray;
		if( array.isValid )
			{ ^array.writeWFSFile(path, name) }
			{ "this is not an Array containing WFSPaths".error };
	}
	
	writeSVGFile { |path =  "~/scwork/wfsPathsOut.svg", name="example"|
		var array;
		array = this.asWFSPathArray;
		if( array.isValid )
			{ ^array.writeSVGFile(path, name) }
			{ "this is not an Array containing WFSPaths".error };
	}
}
+ String {
	asWFSPoint { ^nil }
	asWFSSpeaker {^nil }
	asWFSPath { ^nil }
}

+ Number { 
	asWFSPoint { |amount = 3| // fill in the number at all slots or only 1 or 2
		^WFSPoint(*this.dup(amount)) }
		
	asWFSSpeaker { |angle = 0| ^this.asWFSPoint.asWFSSpeaker(angle) }
	
	couldBeWFSPoint { ^true }
	}

+ Point {
	asWFSPoint { |z = 0| ^WFSPoint(x,y,z); }
	asWFSSpeaker { |z=0, angle=0| ^WFSSpeaker(x,y,z,angle) }
	
	couldBeWFSPoint { ^true }
	}

