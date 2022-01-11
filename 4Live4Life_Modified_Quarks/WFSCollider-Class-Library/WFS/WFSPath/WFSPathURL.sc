/*
    GameOfLife WFSCollider - Wave Field Synthesis spatialization for SuperCollider.
    The Game Of Life Foundation. http://gameoflife.nl
    Copyright 2006-2011 Wouter Snoei.

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

/*
WFSPathURL manages file locations for WFSPath2. It makes sure only one url is
associated with a specific path. If the url is changed it makes a copy of the path 
for on the old url, and if a path was already on an url it moves it into "orphaned".

WFSPathURL behaves like a WFSPath2 in all other 

*/

WFSPathURL {
	
	classvar <>all;
	classvar <>orphaned;
	
	var url;
	
	*initClass { 
		all = IdentityDictionary(); 
		
	}
	
	*new { |url|
		url = this.formatURL( url );
		^this.newCopyArgs( url ).init;
	}
	
	init {
		var wfsPath;
		wfsPath = this.class.getWFSPath( url );
		if( wfsPath.isNil ) {
			WFSPath2.read( url.asString ); // can return nil if file not available
		};
		this.changed( \init );
	}
	
	*formatURL { |url|
		if( url.notNil ) {
			^url.asString.formatGPath.asSymbol;
		} {
			^nil;
		};
	}
	
	*getWFSPath { |url|
		url = this.formatURL( url );
		^all[ url ];
	}
	
	*getURL { |wfsPath|
		all.keysValuesDo({ |key, value|
			if( value === wfsPath ) { ^key.asString };
		});
		^nil;
	}
	
	*putWFSPath { |url, wfsPath, keepOld = true|
		var oldPath, oldURL;
		if( keepOld ) {
			if( ( oldPath = this.getWFSPath( url ) ).notNil ) {
				orphaned = orphaned.add( oldPath );
			};
		};
		if( ( oldURL = this.getURL( wfsPath ) ).notNil ) {
			all.put( oldURL.asSymbol, wfsPath.deepCopy );
		};
		if( url.notNil ) {
			all.put( this.formatURL( url ), wfsPath );
		};
	}
	
	wfsPath {
		^all[ url ];
	}
	
	draw { |drawMode = 0, selected, pos, showControls = false, pixelScale = 1|
		if( this.wfsPath.notNil ) {
			this.wfsPath.draw( drawMode, selected, pos, showControls, pixelScale );
		};
	}
	
	url_ { |url|
		url = this.class.formatURL( url );
		this.init;
	}
	
	url { ^url.asString }
	
	filePath { ^this.doesNotUnderstand( \filePath ) ?? { this.url; } }
	
	doesNotUnderstand { |selector ...args|
		var res, wfsPath;
		wfsPath = this.wfsPath;
		if( wfsPath.isNil ) {
			^nil;
		} {
			res = wfsPath.perform( selector, *args );
			if( res === wfsPath ) {
				^this;
			} {
				^res;
			};
		};
	}
	
	size { ^if( this.wfsPath.notNil ) { this.wfsPath.size } { nil }; }
	
	dirty { ^if( this.wfsPath.notNil ) { this.wfsPath.dirty } { true }; }
	
	exists { ^this.wfsPath.notNil }
	
	isWFSPath2 { ^true }

	asWFSPath2 { ^this.wfsPath }
	
	storeArgs { ^[ url.asString.formatGPath ] }
	
}