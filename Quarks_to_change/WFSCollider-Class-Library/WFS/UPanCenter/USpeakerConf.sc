USpeakerConf : WFSPointGroup {
	
	classvar <>default;
	classvar <>current;
	
	var listener;
	
	*new { |positions, listener|
		^super.newCopyArgs( positions, listener ).init;
	}
	
	init {
		this.changed( \init );
	}
	
	listener_ { |point| 
		listener = point.asPoint;
		this.changed( \listener );
	}
	
	listener {
		if( listener.isNil ) { this.listener = 0@0; };
		^listener
	}
	
}

USpeakerConfView : WFSMixedView {
	
	var <>type = \speaker;
	
	points { ^(object !? _.positions) ? [] }
	
	points_ { |points|
		points = points.asUSpeakerConf;
		if( this.object.isNil ) {
			this.object = points;
		} {
			if( canChangeAmount ) {
				this.object.positions = points.positions;
			} {
				this.object.positions = this.object.positions.collect({ |item, i|
					points[i] ?? { object[i] };
				});
			};
		};
	}
	
	center { ^this.object.listener }
}

USpeakerConfTransformerView : WFSPointGroupTransformerView {
	
	revertObject { 
		object.positions = objectCopy.positions.deepCopy;
	}
	
	makeObjectCopy {
		objectCopy = object.deepCopy;
	}
	
	makeEditFuncs { |editDefs|
		
		WFSPathGeneratorDef.loadOnceFromDefaultDirectory;
		
		^(editDefs ?? { [ \circleSize, \polygon, \align, \move, \scale, \rotate, \sort ] })			.asCollection 
			.collect(_.asWFSPathTransformer)
			.select(_.notNil);
	}
	
	
}

USpeakerConfEditView : WFSPointGroupEditView {
	viewClass { ^USpeakerConfView }
}

USpeakerConfGUI : WFSPointGroupGUI {
	editViewClass { ^USpeakerConfEditView }
	transformerViewClass { ^USpeakerConfTransformerView }
}

+ Object { 
	isUSpeakerConf { ^false }
}

+ WFSPath2 {
	asUSpeakerConf {
		^USpeakerConf( this.positions.collect(_.asPoint) );
	}
}

+ Collection {
	asUSpeakerConf {
		^USpeakerConf( this.collectAs(_.asPoint, Array) );
	}
}

+ Symbol {
	asUSpeakerConf { |size = 20|
		^USpeakerConf.generate( size, this );
	}
}

+ Nil {
	asUSpeakerConf { 
		^USpeakerConf( { |i| Polar( 8, i.linlin(0,15,0,2pi) ).asPoint  } ! 15 );
	}
}

+ WFSPath_Old {
	asWFSPointGroup {
		^WFSPointGroup( this.positions.collect(_.asPoint) );
	}
}