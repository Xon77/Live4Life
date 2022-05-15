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

SimpleTransformerDef : GenericDef {
	
	classvar <>all;
	classvar <>defsFolders, <>userDefsFolder;
	
	var <>func;	
	var >defaults;
	var <>makeViewsFunc;
	var <>postMakeViewsFunc;
	var >bypassFunc;
	var <>viewHeight = 14;
	
	*new { |name, func, args, defaults|
		^super.new( name, args ).init( func, defaults );
	}
	
	objectClass { ^SimpleTransformer }
	
	init { |inFunc, inDefaults|
		defaults = inDefaults ? defaults;
		func = inFunc ? func;
	}
	
	defaultBypassFunc { ^{ |f, obj| f.defaults( obj ) == f.args }; }
	
	bypassFunc { ^bypassFunc ? this.defaultBypassFunc }
	
	checkBypass { |f, obj| ^this.bypassFunc.value( f, obj ) == true  }
	
	defaults { |f, obj|
		^defaults !? { defaults.value( f, obj ) } ?? { this.args };
	}
	
}

SimpleTransformer : ObjectWithArgs {
	
	classvar <>nowExecuting;
	
	var <>action;
	var <defName;
	var <>makeCopy = false;
	
	var <>changeDefNameAction;
	var <>environment;
	
	*new { |defName, args|
		^super.new.init( defName, args ? [] )
	}
	
	*defClass { ^SimpleTransformerDef }
	
	*fromDefName { |name, args|
		var def;
		def = this.defClass.fromName( name );
		if( def.notNil ) {
			^def.objectClass.new( name, args );
		} {
			^nil;
		};
	}
	
	init { |inName, inArgs|
		var def;
		if( inName.isKindOf( this.class.defClass ) ) {
			def = inName;
			defName = def.name;
			if( defName.isNil ) { defName = def };
		} {
			defName = inName;
			def = this.class.defClass.fromName( defName );
		};
		if( def.notNil ) {	
			args = def.asArgsArray( inArgs ? #[] );
			// defName = def.name;
		} { 
			//defName = inName;
			"% defName '%' not found".format(this.class.defClass, inName).warn; 
		};
		environment = ();
		this.changed( \init );
	}
	
	def { 
		if( defName.isKindOf( this.class.defClass ) ) {
			^defName
		} {
			^this.class.defClass.fromName( defName );
		};
	}
	
	def_ { |newDef, keepArgs = true|
		this.init( newDef, if( keepArgs ) { args } { nil } );
		changeDefNameAction.value;
	}
	
	defName_ { |newName, keepArgs = true|
		this.init( newName, if( keepArgs ) { args } { nil } );
		changeDefNameAction.value;
	}
	
	defaults { |obj| ^this.def.defaults( this, obj ); }
	
	getSpec { |key| ^this.def.getSpec( key ) }
	
	set { |argName, value, constrain = false|
		var spec;
		if( constrain && { (spec = this.getSpec( argName )).notNil } ) { 
			value = spec.constrain( value );
		};
		this.setArg( argName, value );
	}
	
	get { |key|
		^this.getArg( key );
	}
	
	args_ { |newArgs, constrain = false|
		newArgs.pairsDo({ |argName, value|
			this.set( argName, value, constrain );
		});
	}
	
	doesNotUnderstand { |selector ...args| 
		if( selector.isSetter ) { 
			this.set( selector.asGetter, *args ) 
		} {
			^this.get( selector );
		};	
	}
	
	rate { ^this.get( \rate ) }
	loop { ^this.get( \loop ) }
	size { ^this.get( \size ) }
	
	
	reset { |obj| // can use an object to get the defaults from
		this.args = this.defaults( obj );
	}
	
	checkBypass { |obj| ^this.def.checkBypass( this, obj ) }
	
	value { |obj, args|
		var res;
		this.args = args;
		if( makeCopy ) { obj = obj.deepCopy };
		nowExecuting = this;
		if( this.checkBypass( obj ) ) {
			res = obj;
		} {
			res = this.prValue( obj );
		};
		nowExecuting = nil;
		^res;

	}
	
	prValue { |obj|
		^this.def.func.value( this, obj );
	}
	
	printOn { arg stream;
		stream << "a " << this.class.name << "(" <<* this.storeArgs  <<")"
	}
	
	getInitArgs {
		var defArgs;
		defArgs = (this.def.args( this ) ? []).clump(2);
		^args.clump(2).select({ |item, i| 
			item != defArgs[i]
		 }).flatten(1);
	}
	
	storeArgs { 
		var initArgs;
		initArgs = this.getInitArgs;
		if( initArgs.size > 0 ) {
			^[ this.defName, initArgs ];
		} {
			^[ this.defName ];
		};
	}

}