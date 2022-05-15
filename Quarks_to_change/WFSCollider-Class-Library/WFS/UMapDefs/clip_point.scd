/*
\clip_point

Creates an UMap for applying clipping, wrapping, folding (mirroring) and more on points

point: the point to clip
center: the center of the clipping area
radius: the radius of the clipping area
clipMode: can be one of the following modes:
	0 - 'clip' (default): clip coordinates outside clipping area
	1 - 'fold': fold/mirror coordinates outside clipping area
	2 - 'wrap': wrap around coordinates outside clipping area
	3 - 'none': no clipping applied (values can go outside  clipping area)
clipSoftness: softens the edges of 'clip' and 'fold' modes (0-1).

The value arg range is mapped to that of the parameter to which the UMap is connected.

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/


UMapDef( \clip_point, { |
		point = #[0.0, 0.0], 
		center = #[0.0, 0.0], 
		radius = #[10.0, 10.0], 
		clipMode = 0,
		clipSoftness = 0.1|
	radius = radius.max(1.0e-10);
	point = point - center;
	point = point.linlin( radius.neg, radius, -1, 1, \none );
	point = Select.kr( clipMode, [
		point.softclip2(1, clipSoftness ),
		point.softfold2(1, clipSoftness ),
		point.wrap2(1),
		point
	]);
	point = point.linlin( -1, 1, radius.neg, radius, \none ) + center;
	UMapOut.kr(point, false);
})
	.setSpec( \point, WFSPointSpec(200) )
	.setSpec( \center, WFSPointSpec(200) )
	.setSpec( \radius, WFSRadiusSpec(Rect(0,0,200,200)) )
	.setSpec( \clipMode, ListSpec( (..3), 0, [ \clip, \fold, \wrap, \none ] ) )
	.setSpec( \clipSoftness, [0,1,\lin,0,0.1].asSpec )
	.category_( 'point_utility' )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec );
	})