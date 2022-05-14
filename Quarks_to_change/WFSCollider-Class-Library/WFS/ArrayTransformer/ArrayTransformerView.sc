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

ArrayTransformerView {
	
	var <object;
	var <objectCopy;
	var <>editFuncs;
	var <view, <views;
	var <>action;
	var <>onClose;
	
	*new { |parent, bounds, object, spec, editDefs|
		^super.new.init( parent, bounds, object, spec, editDefs )
	}
	
	init { |parent, bounds, inObject, spec, editDefs|
		object = inObject ? object;
		this.makeObjectCopy;
		editFuncs = this.makeEditFuncs( editDefs, spec );
		this.makeView( parent, bounds );	
		this.resetFuncs;
	}
	
	rebuildViews {
		var tempOnClose, parent, bounds;
		var resizeMode;
		tempOnClose = onClose;
		onClose = nil;
		parent = view.parent;
		bounds = view.bounds;
		resizeMode = view.resize;
		view.remove;
		if( parent.asView.decorator.notNil ) {
			parent.asView.decorator.bounds_( parent.asView.bounds.moveTo(0,0) );
			parent.asView.decorator.reFlow( parent.asView );
		};
		this.makeView( parent, bounds );
		view.resize_( resizeMode );
		onClose = tempOnClose;
	}
	
	makeObjectCopy {
		objectCopy = object.deepCopy;
	}
	
	selected {
		^editFuncs[0].selection;
	}
	
	selected_ { |selected|
		editFuncs.do( _.selection_(selected) );
	}
	
	revertObject { 
		object.overWrite( objectCopy, 0 );
	}
	
	object_ { |newObject|
		object = newObject;
		this.resetFuncs;
		this.makeObjectCopy;
	}
	
	resize_ { |resize|
		view.resize_( resize )
	}
	
	apply { |final = true, active = false|
		
		this.revertObject;
		
		if( this.checkBypass.not ) {
			editFuncs.do({ |func|
				object.overWrite( func.value( object ), 0 );
			});
			
			if( final ) {
				this.resetFuncs( false );
				this.makeObjectCopy;
				this.changed( \apply );
			};
		};
	
		^object;
	}
	
	resetFuncs { |all = false|
		editFuncs.do({ |func|
			func.reset( object, all );
		});
	}
	
	checkBypass { 
		var bypass = true;
		editFuncs.do({ |func|
			if( func.checkBypass ( object ).not ) {
				bypass = false;
			};
		});
		^bypass;
	}
	
	reset {
		this.revertObject;
		this.resetFuncs( true );
		this.changed( \reset );
	}
	
	makeView { |parent, bounds|
		
		if( parent.isNil ) {
			bounds = bounds ?? { 220 @ 500 };
		};
		
		view = EZCompositeView( parent ? this.class.name.asString, bounds, true, 2@2, 2@2 );
		
		
		this.makeViews;
		
		view.view.decorator.nextLine;
		
		view.decorator.shift( 65, 0 );
		
		views[ \apply ] = SmoothButton( view, 40@14 )
			.font_( Font( Font.defaultSansFace, 10 ) )
			.label_( "apply" )
			.border_( 1 )
			.radius_( 2 )
			.action_({ 
				this.apply( true );
				action.value( this, \apply )
			});
			
		views[ \reset ] = SmoothButton( view, 40@14 )
			.font_( Font( Font.defaultSansFace, 10 ) )
			.label_( "reset" )
			.border_( 1 )
			.radius_( 2 )
			.action_({ 
				this.reset;
				action.value( this, \reset );
			});
		
		view.view.bounds = view.view.bounds.height_( view.view.children.last.bounds.bottom );
		
		view.onClose_({ this.onClose.value });
	}
	
	makeViews {
		views = ();
		
		editFuncs.collect({ |func|
			var key;
			key = func.defName;
			func.action = { 
				this.apply( false );
				action.value( this, key );
			};
			func.changeDefNameAction = {
				this.rebuildViews;
				this.apply( false );
				action.value( this, \changeDefName );
			};
			views[ key ] = func.makeViews( view, view.bounds );
			view.view.decorator.nextLine;
		});
		
		//this.reset; 
	}
	
	makeEditFuncs { |editDefs, spec|
		
		ArrayTransformerDef.loadOnceFromDefaultDirectory;
		ArrayGeneratorDef.loadOnceFromDefaultDirectory;
		
		^(editDefs ?? { [ 
			\line, \random, \offset, \scale, \tilt, \curve, \smooth, \round, \rotate, \sort
		] })	
			.asCollection 
			.collect({ |item| ArrayTransformer.fromDefName( item ) })
			.select(_.notNil)
			.collect(_.spec_( spec ));
	}
	
	spec_ { |spec|
		editFuncs.do(_.spec_( spec ) );
	}
	
	editDefs { ^editFuncs }
	
	editDefs_ { |editDefs|
		editFuncs = this.makeEditFuncs( editDefs );
		this.rebuildViews;
		this.apply( false );
		action.value( this, \editDefs );
	}
}