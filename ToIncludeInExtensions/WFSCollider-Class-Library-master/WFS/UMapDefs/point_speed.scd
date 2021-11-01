/*
\point_speed

Creates an UMap for measuring the speed of a point (or point UMap) and convert it to a value.

point: the point
fromRange: the speed range from which the output value will be calculated
toRange: the value range to which the speed range will be mapped
clipMode: when the speed is outside the fromRange, the clipMode decides what happens
	0 - 'clip' (default): clip inside the value range
	1 - 'fold': fold/mirror inside the value range
	2 - 'wrap': wrap around the value range
	3 - 'none': no clipping applied (values can go outside the value range)
clipSoftness: softens the edges of 'clip' and 'fold' modes (0-1).

The 'toRange' arg range is mapped to that of the parameter to which the UMap is connected.

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/


UMapDef( \point_speed, { |
		point = #[0.0, 0.0],
		fromRange = #[0, 20],
		toRange = #[0.0,1.0],
		clipMode = 0,
		clipSoftness = 0.0|
	var value;
	value = ((point - Delay1.kr( point )) * ControlRate.ir).asPoint.rho;
	value = value.linlin( *fromRange ++ [-1,1, \none ] );
	value = Select.kr( clipMode, [
		value.softclip2(1, clipSoftness ),
		value.softfold2(1, clipSoftness ),
		value.wrap2(1),
		value
	]);
	value = value.linlin( -1, 1, *toRange ++ [\none] );
	UMapOut.kr( value );
})
	.mappedArgs_( [ \toRange ] )
	.setSpec( \point, WFSPointSpec(200,0.1) )
	.setSpec( \fromRange, [0,344].asSpec.asRangeSpec )
	.setSpec( \clipMode, ListSpec( (..3), 0, [ \clip, \fold, \wrap, \none ] ) )
	.setSpec( \clipSoftness, [0,1,\lin,0,0.0].asSpec )
	.category_( 'point_to_value' )