ArrayTransformer : SimpleTransformer {
	
	var <selection;
	var <spec;
	var unmapMappedArgs = false;
	var <>mapIO = false;
	
	*defClass { ^ArrayTransformerDef }
	
	prValue { |obj|
		var def;
		def = this.def;
		obj = obj.asCollection;
		if( def.useSelection.value( this, obj ) && { selection.size > 0 } ) {
			^this.prValueSelection( obj, def )
		} {
			^this.applyFunc( obj, def );
		};
	}
	
	getSpec { |key| 
		if( spec.notNil && { (this.def.mappedArgs ? #[]).includes( key ) }) {
			^this.def.getSpec( key ).adaptToSpec( spec );
		} {
			^this.def.getSpec( key )
		};
		
	}
	
	spec_ { |inSpec|
		if( spec.notNil && { spec != inSpec }) {
			this.def.mappedArgs.do({ |key|
				this.set( key, this.getSpec( key ).unmap( this.get( key ) ) );
			});
			spec = nil;
		};
		if( spec.isNil && { inSpec.notNil }) {
			spec = inSpec.asSpec;
			this.def.mappedArgs.do({ |key|
				this.set( key, this.getSpec( key ).map( this.get( key ) ) );
			});
		};
	}
	
	def_ { |newDef, keepArgs = true|
		var sp;
		sp = this.spec;
		this.spec = nil;
		this.init( newDef, if( keepArgs ) { args } { nil } );
		this.spec = sp;
		changeDefNameAction.value;
	}
	
	defName_ { |newName, keepArgs = true|
		this.def_( newName, keepArgs );
	}
	
	set { |argName, value, constrain = false|
		var spec;
		if( constrain && { (spec = this.getSpec( argName )).notNil } ) { 
			value = spec.constrain( value );
		};
		this.setArg( argName, value );
	}
	
	get { |key|
		if( unmapMappedArgs && { this.def.mappedArgs.includes( key ) } ) {
			^this.getSpec( key ).unmap( this.getArg( key ) );
		} {
			^this.getArg( key );
		};
	}
	
	getMapped { |key|
		^this.getArg( key );
	}
	
	applyFunc { |obj, def|
		var res;
		def = def ?? { this.def };
		if( mapIO && spec.notNil ) {
			obj = spec.unmap( obj );
		};
		unmapMappedArgs = true;
		res = this.prApplyFunc( obj, def );
		unmapMappedArgs = false;
		if( mapIO && spec.notNil ) {
			^spec.map( res );
		} {
			^res;
		};
	}
	
	prApplyFunc { |obj, def|
		^def.func.value( this, obj );
	}
	
	prValueSelection { |obj, def|
		var result, size, sel;
		size = obj.size;
		sel = selection.select({ |item| item < size });
		result = this.applyFunc( obj[ sel ], def );
		sel.do({ |index, i|
			obj.put( index, result[i] );
		});
		^obj;
	}
	
	selection_ { |newSelection| selection = newSelection; this.changed( \selection, selection ); }
}

ArrayGenerator : ArrayTransformer {
	
	
	// \bypass, \replace, \+, \-, \*, <any binary operator>
	var <mode = \replace;
	
	var <blend = 1; // 0 to 1
	
	*defClass { ^ArrayGeneratorDef }
	
	prApplyFunc { |obj, def|
		var result, size;
		size = obj.size;
		result = def.func.value( this, size, obj );
		^switch( mode,
			\replace, { 
				obj.blend( result, blend );
			},
			\lin_xfade, {
				obj.blend( result, blend * ((..size-1)/(size-1)) );
			},
			\bypass, { obj },
			{
				result = result.perform( mode, obj );
				obj.blend( result, blend );
			}
		);
	}
	
	reset { |obj, all = false| // can use an object to get the defaults from
		this.blend = 0;
		//if( all == true ) {
			this.args = this.defaults( obj );
		//};
	}
	
	mode_ { |newMode| mode = newMode; this.changed( \mode, mode )  }
	blend_ { |val = 1| blend = val; this.changed( \blend, blend )  }
	
	storeModifiersOn{|stream|
		if( blend != 1 ) {
			stream << ".blend_(" <<< blend << ")";
		};
		if( mode !== \replace ) {
			stream << ".mode_(" <<< mode << ")";
		};
	}
}

ArrayTransformerDef : SimpleTransformerDef {
	classvar <>all;
	classvar <>defsFolders, <>userDefsFolder;
	
	var <>useSelection = true;
	var >mappedArgs;
	
	*initClass{
		defsFolders = [ 
			this.filenameSymbol.asString.dirname +/+ "ArrayTransformerDefs"
		];
		userDefsFolder = Platform.userAppSupportDir ++ "/ArrayTransformerDefs/";
	}
	
	mappedArgs { ^mappedArgs ? #[] }
	
	objectClass { ^ArrayTransformer }
	
	defaults { |f, obj|
		var res;
		if( mappedArgs.size > 0 && { f.spec.notNil } ) {
			if( f.mapIO ) { obj = f.spec.unmap( obj ) };
			res = defaults !? { defaults.value( f, obj ) } ?? { this.args };
			mappedArgs.do({ |key|
				var i;
				i = res.indexOf( key );
				if( i.notNil ) {
					res[i+1] = f.getSpec( key ).map( res[i+1] );
				};
			});
			^res;
		} {
			^defaults !? { defaults.value( f, obj ) } ?? { this.args };
		};
	}
}

ArrayGeneratorDef : ArrayTransformerDef {
	
	classvar <>defsFolders, <>userDefsFolder;
	
	*initClass{
		defsFolders = [ 
			this.filenameSymbol.asString.dirname +/+ "ArrayGeneratorDefs"
		];
		userDefsFolder = Platform.userAppSupportDir ++ "/ArrayGeneratorDefs/";
	}
	
	defaultBypassFunc { 
		^{ |f, obj|
			(f.blend == 0) or: { f.mode === \bypass };
		};
	}
	
	objectClass { ^ArrayGenerator }	

}