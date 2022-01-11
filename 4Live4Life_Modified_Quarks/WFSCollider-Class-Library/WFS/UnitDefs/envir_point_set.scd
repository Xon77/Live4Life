/*
\envir_point_set

** this Udef can be used in conjunction with 'envir_point_get' and 'p_envir_point_get' UMaps **

The 'envir_point_set' Udef creates a unit that is able to globally share a value with other units used further in the chain, or in other chains. To use the value within the same chain, an 'envir_point_set' unit should always be first in the order of the chain. It makes the value available as an Environment value, which is globally accessible. To retreive the value in an other unit use the 'p_envir_point_get' or 'envir_point_get' UMapDef, and make sure the 'key' setting is the same on both. The value is can also be accessed via SuperCollider code, by adding a '~' in front of the name. The value can be set in 5 different formats: value (0-1), freq (2-20000), amp (0-1, curved for amplitude use), boolean (true/false) and time (0-inf). The 'p_envir_point_get' UMapDef will automatically map the value to the range of the parameter it is connected to, which means it is possible to use for example the 'freq' value of this unit to influence the 'amp' value of another unit. The 'envir_point_set' unit itself does not output any sound, it only makes the value available.

point: the point to share (can be UMap, but only from a function, control, midi or pattern category)
key: the name of the variable (default: 'a')

--
this is an Udef definition file
part of the WFSCollider Class Library default UDefs set
*/

FreeUdef( \envir_point_set, [
		[ \point, 0@0, WFSPointSpec(200), false, \init ],
		[ \key, \p, SymbolSpec() ],
	])
	.apxCPU_( 0 )
	.prepareFunc_({ |server, unit, action, startPos = 0|
		var value;
		value = unit.get( \point );
		unit.get( \key ).asSymbol.uEnvirPut( value.value, WFSPointSpec(200) );
		if( value.isKindOf( UMap ) ) { 
			value.start 
		};
		action.value;
	})
	.createsSynth_( false )
	.setSynthFunc_({ |unit ...keyValuePairs|
		unit.get( \key ).asSymbol.uEnvirPut( unit.get( \point ).value, WFSPointSpec(200) );
	})
	.category_( 'envir' );