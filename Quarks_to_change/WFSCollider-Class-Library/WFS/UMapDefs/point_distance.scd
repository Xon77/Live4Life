/*
\point_distance

Creates an UMap for converting the distance between two points (or point UMaps) to a value range.

point1: the first point
point2: the second point
fromRange: the distance range from which the output value will be calculated
toRange: the value range to which the distance range will be mapped
invert: (boolean) if true the distance range will be inverted
clipMode: when the distance is outside the fromRange, the clipMode decides what happens
	0 - 'clip' (default): clip inside the value range
	1 - 'fold': fold/mirror inside the value range
	2 - 'wrap': wrap around the value range
	3 - 'none': no clipping applied (values can go outside the value range)
clipSoftness: softens the edges of 'clip' and 'fold' modes (0-1).

The toRange arg range is mapped to that of the parameter to which the UMap is connected.

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

UMapDef( \point_distance, { |
		point1 = #[0.0, 0.0], 
		point2 = #[0.0, 0.0], 
		fromRange = #[0, 20],
		toRange = #[0.0,1.0],	
		invert = 0,
		clipMode = 0,
		clipSoftness = 0.0|
	var dist;
	dist = point1.asPoint.dist( point2.asPoint );
	dist = dist.linlin( *fromRange ++ [-1,1, \none ] );
	dist = dist * invert.linlin(0,1,1,-1,\none);
	dist = Select.kr( clipMode, [
		dist.softclip2(1, clipSoftness ),
		dist.softfold2(1, clipSoftness ),
		dist.wrap2(1),
		dist
	]);
	dist = dist.linlin( -1, 1, *toRange ++ [\none] );
	UMapOut.kr( dist );
})
	.mappedArgs_( [ \toRange ] )
	.setSpec( \point1, WFSPointSpec(200) )
	.setSpec( \point2, WFSPointSpec(200) )
	.setSpec( \fromRange, [0,400].asSpec.asRangeSpec )
	.setSpec( \invert, BoolSpec(false) )
	.setSpec( \clipMode, ListSpec( (..3), 0, [ \clip, \fold, \wrap, \none ] ) )
	.setSpec( \clipSoftness, [0,1,\lin,0,0.1].asSpec )
	.category_( 'point_to_value' )