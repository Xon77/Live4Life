/*
\point_angle

Creates an UMap for converting the angle between two points (or point UMaps) to a value range.

point1: the first point
point2: the second point
centerAngle: the reference angle (subtracted from the absolute angle)
fromRange: the angle range from which the output value will be calculated, divided by pi
toRange: the value range to which the angle range will be mapped
invert: (boolean) if true the angle range will be inverted
clipMode: when the angle is outside the fromRange, the clipMode decides what happens. The angle is "unwrapped" internally, so if the point would for example spin multiple times it will go outside the clipping area.
	0 - 'clip': clip inside the value range
	1 - 'fold': fold/mirror inside the value range
	2 - 'wrap' (default): wrap around the value range
	3 - 'none': no clipping applied (values can go outside the value range)
clipSoftness: softens the edges of 'clip' and 'fold' modes (0-1).

The toRange arg range is mapped to that of the parameter to which the UMap is connected.

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

UMapDef( \point_angle, { |
		point1 = #[0.0, 0.0], 
		point2 = #[0.0, 0.0], 
		centerAngle = 0,
		fromRange = #[-1, 1],
		toRange = #[0.0,1.0],	
		invert = 0,
		clipMode = 2,
		clipSoftness = 0.0|
	var angle;
	angle = (point1 - point2).asPoint.angle - centerAngle;
	angle = angle.wrap(-pi, pi).unwrap(-pi,pi);
	angle = angle.linlin( *(fromRange * pi) ++ [-1,1, \none ] );
	angle = angle * invert.linlin(0,1,1,-1,\none);
	angle = Select.kr( clipMode, [
		angle.softclip2(1, clipSoftness ),
		angle.softfold2(1, clipSoftness ),
		angle.wrap2(1),
		angle
	]);
	angle = angle.linlin( -1, 1, *toRange ++ [\none] );
	UMapOut.kr( angle );
})
	.mappedArgs_( [ \toRange ] )
	.setSpec( \point1, WFSPointSpec(200) )
	.setSpec( \point2, WFSPointSpec(200) )
	.setSpec( \centerAngle, AngleSpec() )
	.setSpec( \fromRange, [-1,1].asSpec.asRangeSpec )
	.setSpec( \invert, BoolSpec(false) )
	.setSpec( \clipMode, ListSpec( (..3), 0, [ \clip, \fold, \wrap, \none ] ) )
	.setSpec( \clipSoftness, [0,1,\lin,0,0.0].asSpec )
	.category_( 'point_to_value' )