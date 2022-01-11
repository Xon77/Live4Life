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

WFSPathTransformerDef : SimpleTransformerDef {
	
	classvar <>all;
	classvar <>defsFolders, <>userDefsFolder;
	
	var <>useSelection = true;
	
	*initClass{
		defsFolders = [ 
			this.filenameSymbol.asString.dirname +/+ "WFSPathTransformerDefs"
		];
		userDefsFolder = Platform.userAppSupportDir ++ "/WFSPathTransformerDefs/";
	}
	
	objectClass { ^WFSPathTransformer }
}

WFSPathGeneratorDef : WFSPathTransformerDef {
	
	classvar <>defsFolders, <>userDefsFolder;
	
	var <>changesX = true;
	var <>changesY = true;
	var <>changesT = true;
	
	*initClass{
		defsFolders = [ 
			this.filenameSymbol.asString.dirname +/+ "WFSPathGeneratorDefs"
		];
		userDefsFolder = Platform.userAppSupportDir ++ "/WFSPathGeneratorDefs/";
	}
	
	defaultBypassFunc { 
		^{ |f, obj|
			(f.blend == 0) or: {
				(f.modeT === \bypass) and: {
					(f.modeX === \bypass) and:  {
						(f.modeY === \bypass)
					}
				}
			};
		};
	}
	
	objectClass { ^WFSPathGenerator }	

}

WFSPathTransformer : SimpleTransformer {
	
	var <selection;
	
	*defClass { ^WFSPathTransformerDef }
	
	prValue { |obj|
		var def;
		def = this.def;
		if( def.useSelection.value( this, obj ) && { selection.size > 0 } ) {
			^this.prValueSelection( obj, def )
		} {
			^this.applyFunc( obj, def );
		};
	}
	
	applyFunc { |obj, def|
		def = def ?? { this.def };
		^def.func.value( this, obj );
	}
	
	prValueSelection { |obj, def|
		var result;
		result = this.applyFunc( obj.copySelection( selection ), def );
		obj.putSelection( selection, result );
		^obj;
	}
	
	selection_ { |newSelection| selection = newSelection; this.changed( \selection, selection ); }
	
	asWFSPathTransformer { ^this }
	asWFSPathGenerator { ^this } // these are exchangeable
	
}


WFSPathGenerator : WFSPathTransformer {
	
	// \bypass, \replace, \+, \-, \*, <any binary operator>
	var <modeX = \replace;
	var <modeY = \replace;
	var <modeT = \replace;
	
	var <blend = 1; // 0 to 1

	var <polar = false;
	
	*defClass { ^WFSPathGeneratorDef }
	
	applyFunc { |obj, def|
		var copy, result;
		var newX, newY, newT;
		var size;
		copy = obj.deepCopy;
		def = def ?? { this.def };
		if( polar ) {
			copy.positions = copy.positions.collect({ |item|
				Point( item.rho, item.theta );
			});
			result = def.func.value( this, copy, copy.positions.size );
			result.positions = copy.positions.collect({ |item|
				Polar( item.x, item.y ).asPoint;
			});
		} {
			result = def.func.value( this, copy, copy.positions.size );
		};
		
		if( def.changesX ) {
			newX = result.positions.collect(_.x);
			size = newX.size;
			obj.positions.do({ |item, i|
				var x;
				switch( modeX,
					\replace, { 
						x = newX[i]; 
						item.x = item.x.blend( x, blend );
					},
					\lin_xfade, {
						x = newX[i];
						item.x = item.x.blend( x, blend * (i/(size-1)) );
					},
					\bypass, { },
					{
						x = item.x.perform( modeX, newX[i] );
						item.x = item.x.blend( x, blend );
					}
				);
				
			});
		};
		
		if( def.changesY ) {
			newY = result.positions.collect(_.y);
			obj.positions.do({ |item, i|
				var y;
				switch( modeY,
					\replace, { 
						y = newY[i]; 
						item.y = item.y.blend( y, blend );
					},
					\lin_xfade, {
						y = newY[i];
						item.y = item.y.blend( y, blend * (i/(size-1)) );
					},
					\bypass, { },
					{
						y = item.y.perform( modeY, newY[i] );
						item.y = item.y.blend( y, blend );
					}
				);
			});
		};
		
		if( def.changesT ) {
			newT = result.times;
			obj.times = obj.times.collect({ |item, i|
				var t;
				switch( modeT,
					\replace, { 
						t = newT[i]; 
						item.blend( t, blend );
					},
					\lin_xfade, {
						t = newT[i];
						item.blend( t, blend * (i/(size-1)) );
					},
					\bypass, { item },
					{
						t = item.perform( modeT, newT[i] );
						item.blend( t, blend );
					}
				);
			});
		};
		
		^obj;
	}
	
	reset { |obj, all = false| // can use an object to get the defaults from
		this.blend = 0;
		if( all == true ) {
			this.args = this.defaults( obj );
		};
	}
	
	modeX_ { |newModeX| modeX = newModeX; this.changed( \modeX, modeX )  }
	modeY_ { |newModeY| modeY = newModeY; this.changed( \modeY, modeY )  }
	modeT_ { |newModeT| modeT = newModeT; this.changed( \modeT, modeT )  }
	blend_ { |val = 1| blend = val; this.changed( \blend, blend )  }
	polar_ { |bool = false| polar = bool; this.changed( \polar, polar )  }
	
	storeModifiersOn{|stream|
		if( blend != 1 ) {
			stream << ".blend_(" <<< blend << ")";
		};
		if( (modeX !== \replace) && { this.def.changesX } ) {
			stream << ".modeX_(" <<< modeX << ")";
		};
		if( (modeY !== \replace) && { this.def.changesY } ) {
			stream << ".modeY_(" <<< modeY << ")";
		};
		if( (modeT !== \replace) && { this.def.changesT } ) {
			stream << ".modeT_(" <<< modeT << ")";
		};
		if( polar ) {
			stream << ".polar_(" <<< polar << ")";
		};
	}
	
	asWFSPathTransformer { ^nil } // cannot be used as transformer
	asWFSPathGenerator { ^this } 

}

+ Symbol {
	asWFSPathTransformer { |args| ^WFSPathTransformer.fromDefName( this, args ) }
	asWFSPathGenerator { |args| ^WFSPathGenerator.fromDefName( this, args ) }
}

+ Collection {
	asWFSPathTransformer { ^WFSPathTransformer.fromDefName( this[0], this[1] ) }
	asWFSPathGenerator { ^WFSPathGenerator.fromDefName( this[0], this[1] ) }
}

