WFSPositionTracker {
	
	classvar <>all;
	classvar <>positions;
	classvar <>types;
	classvar <sendPointRate = 10;
	classvar <active = false;
	
	*initClass {
		all = IdentityDictionary();
		positions = IdentityDictionary();
		types = IdentityDictionary();
	}
	
	*start {
		UChain.addDependant( this );
		this.active = true;
	}
	
	*stop {
		UChain.removeDependant( this );
		this.active = false;
		this.rate = sendPointRate;
		this.clear;
	}
	
	*active_ { |bool|
		active = bool;
		this.changed( \active, bool );
	}
	
	*clear {
		all.do({ |xx| xx.do({ |item| item.remove }); });
		all.clear;
		positions.clear;
		types.clear;
	}
	
	*update { |obj, groupDict, mode, uchain|
		switch( mode,
			\add, { this.add( uchain ) },
			\remove, { this.remove( uchain ) }
		); 
	}
	
	*rate_ { |rate = 10|
		sendPointRate = rate;
		Server.all.do({ |srv|
			RootNode(srv).set( \sendPointRate, this.getRate );
		});
		this.changed( \rate, sendPointRate );
	}
	
	*getRate { ^sendPointRate * active.binaryValue }
	
	*add { |uchain|
		var pannerUnits, repliers;
		var typeDict = Order();
		this.remove( uchain );
		uchain.units.do({ |unit, i|
			case { [ 
					\wfsStaticPoint, 
					\wfsDynamicPoint, 
					\wfsDynamicDirectional,
				].includes( unit.name ) or: {
					unit.name === \wfsSource && {
						unit.type === \point;
					}
				}
			} {
				pannerUnits = pannerUnits.add( unit );
				typeDict[ i ] = \point;
			} { [ 
					\wfsStaticPlane, 
					\wfsDynamicPlane 
				].includes( unit.name ) or: {
					unit.name === \wfsSource && {
						unit.type === \plane;
					}
				}
			} {
				pannerUnits = pannerUnits.add( unit );
				typeDict[ i ] = \plane;
			};
		});
		if( pannerUnits.size > 0 ) {
			repliers = pannerUnits.collect({ |unit, i|
				var synth, unitIndex;
				synth = unit.synths[1]; // prepan synth is always second synth
				unitIndex = uchain.units.indexOf( unit );
				if( synth.notNil ) {
					ReceiveReply( synth, { |point, time, resp, msg|
						positions[ uchain ] !? { 
							if( positions[ uchain ][ unitIndex ].notNil ) {
								positions[ uchain ][ unitIndex ].x = point[0];
								positions[ uchain ][ unitIndex ].y = point[1];
							} {
								positions[ uchain ][ unitIndex ] = point.asPoint;
							};
						};
					}, '/point' );
				};
			}).select(_.notNil);
			if( repliers.size > 0 ) {
				all[ uchain ] = repliers;
				positions[ uchain ] = Order();
				types[ uchain ] = typeDict;
			};
		};
	}
	
	*remove { |uchain|
		all[ uchain ].do({ |item| item.remove });
		all[ uchain ] = nil;
		positions[ uchain ] = nil;
		types[ uchain ] = nil;
	}
	
	*list {
		var objects;
		positions.keysValuesDo({  |uchain, points|
			points.do({ |point, i|
				objects = objects.add( [point, uchain, i] );
			});
		});
		^objects;
	}
	
	*pointsAndLabels {
		var objects;
		positions.keysValuesDo({  |uchain, points|
			points.do({ |point, i|
				var color;
				color = uchain.getTypeColor;
				if( color.isKindOf( Color ).not ) {
					color = Color.blue(0.5,0.75); 
				};
				objects = objects.add( [
					point,  
					uchain.name ++ [ i ].asString, 
					types[ uchain ][i], // and source types
					color // and display colors
				] );
			});
		});
		^(objects ? []).flop;
	}
	
	*points {
		^positions.values.collect(_.asArray).flatten(1);
	}
}