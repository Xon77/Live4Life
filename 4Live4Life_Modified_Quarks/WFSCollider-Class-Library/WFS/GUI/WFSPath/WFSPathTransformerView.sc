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

WFSPathTransformerView {
	
	var <object;
	var <objectCopy;
	var <>editFuncs;
	var <view, <views;
	var <>action;
	var <>duplicateAction;
	var <>onClose;
	
	*new { |parent, bounds, object, editDefs|
		^super.new.init( parent, bounds, object, editDefs )
	}
	
	init { |parent, bounds, inObject, editDefs|
		object = inObject ? object;
		this.makeObjectCopy;
		editFuncs = this.makeEditFuncs( editDefs );
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
			parent.asView.decorator.reFlow( parent.asView );
		};
		this.makeView( parent, bounds );
		view.resize_( resizeMode );
		onClose = tempOnClose;
	}
	
	makeObjectCopy {
		if( object.isKindOf( WFSPathURL ) ) {
			objectCopy = object.wfsPath.deepCopy; // copy the associated trajectory
		} {
			objectCopy = object.deepCopy;
		}
	}
	
	selected {
		^editFuncs[0].selection;
	}
	
	selected_ { |selected|
		editFuncs.do( _.selection_(selected) );
	}
	
	revertObject { 
		object.positions = objectCopy.positions.deepCopy;
		object.times = objectCopy.times.deepCopy;
		object.type = objectCopy.type;
		object.curve = objectCopy.curve;
		object.clipMode = objectCopy.clipMode;
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
				func.value( object );
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
			if( func.checkBypass( object ).not ) {
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
			bounds = bounds ?? { 177 @ 280 };
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
		 
	}
	
	makeEditFuncs { |editDefs|
		^(editDefs ?? { [ 
			\name, \type, \move, \scale, \rotate, \smooth, \size, \clip, \sort, \duration, \equal, \reverse 
		] })	
			.asCollection 
			.collect(_.asWFSPathTransformer)
			.select(_.notNil);
	}
	
	editDefs { ^editFuncs }
	
	editDefs_ { |editDefs|
		editFuncs = this.makeEditFuncs( editDefs );
		this.rebuildViews;
		this.apply( false );
		action.value( this, \editDefs );
	}
	
	
}

WFSPathGeneratorView : WFSPathTransformerView {
	
	editDefs { ^editFuncs[2..] }

	makeEditFuncs { |editDefs|
		var prepfuncs;
		
		WFSPathGeneratorDef.loadOnceFromDefaultDirectory;
		
		if( editFuncs.notNil ) {
			prepfuncs = editFuncs[..1];
		} {
			prepfuncs = [ WFSPathTransformer( \simpleSize ), WFSPathTransformer( \duration ) ];
		};
		
		^prepfuncs ++ (editDefs ?? { [ 
				\circle 
			] })	
				.asCollection 
				.collect(_.asWFSPathGenerator)
				.select(_.notNil);
	}
	
}

WFSPointGroupTransformerView : WFSPathTransformerView {
	
	revertObject { 
		object.positions = objectCopy.positions.deepCopy;
	}
	
	makeObjectCopy {
		objectCopy = object.deepCopy;
	}
	
	makeEditFuncs { |editDefs|
		
		WFSPathGeneratorDef.loadOnceFromDefaultDirectory;
		
		^(editDefs ?? { [ \circle, \line, \move, \scale, \rotate, \clip, \sort ] })			.asCollection 
			.collect(_.asWFSPathTransformer)
			.select(_.notNil);
	}
	
	
}
