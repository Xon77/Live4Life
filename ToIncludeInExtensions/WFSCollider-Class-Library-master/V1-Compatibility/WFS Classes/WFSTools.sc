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

WFSTools {

	*makeWFSPointsArray { arg inArray; // for WFSPath
		if(inArray.size < 2)
			{ "A WFSPath should contain at least 2 positions".warn; };
		^inArray.collect({ |item| item.asWFSPoint });
	}
	
	*asRadians { |in| ^(in / WFSPath_Old.azMax) * 2pi; }
	
	*fromRadians { |in| ^(in / 2pi) * WFSPath_Old.azMax; }
	
	*singleAZToXY { arg az, d, center = 0, azMax; // with contol/audio rate support
		var x, y;
		
		azMax = azMax ? WFSPath_Old.azMax;
		if(azMax != 2pi, {az = (az / azMax) * 2pi});
		
		case { az.rate == 'control' }
			{ ^([SinOsc.kr(0, az), SinOsc.kr(0, az - (0.5pi))] * d ) + center; }
			{ az.rate == 'audio' }
			{ ^([SinOsc.ar(0, az), SinOsc.ar(0, az - (0.5pi))] * d ) + center; }
			{ true }
			{ ^([az.sin, az.cos] * d) + center; };
			
		}
	
	*azToXY { arg inArray, center = 0, round = 1.0e-16, azMax; //2D
		azMax = azMax ? WFSPath_Old.azMax;
		^inArray.collect({ |item|
		var azimuth, distance;
		# azimuth, distance = item;
		if(azMax != 2pi, {azimuth = (azimuth / azMax) * 2pi});
		([azimuth.sin.round(round), azimuth.cos.round(round)] * distance) + center;		});
		}
	
	*xyToAZ { arg inArray, center = 0, azMax; //2D
		azMax = azMax ? WFSPath_Old.azMax;
		if(center.class == WFSPoint)	
			{ center = [center.x, center.y]; };
		^inArray.collect({ |item|
				var azimuth, distance, xx, yy;
				#xx, yy = item - center;
				azimuth = atan2(xx,yy) % 2pi; //theta
				distance = hypot(xx,yy); //rho
				if(azMax != 2pi, {azimuth = (azimuth / 2pi) * azMax});
				[azimuth, distance];
			})
		}
	
	*validateTimeLine { |timeLine|
		var lastTime = 0;
		^timeLine.collect({ |item|
			var out;
			if(item < lastTime)
				{ out = item + lastTime; "validateTimeLine: corrected 1 timeLine item".postln; }
				{ out = item;};
			lastTime = out;
			out; });
		}
		
}