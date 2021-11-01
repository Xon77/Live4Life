/*
\mirror_point

Creates an UMap intended that mirrors a point across a line. This can be used for example for creating early reflection positions.

point: the point to rotate (can be an UMap)
plane: the line/plane across which the point is mirrored.
absolute: if true, the point will only be mirrored when it is in front of the line, and thus the mirrored point will always stay behind the line.

--
this is an UMapDef definition file
part of the Unit lib default UMapDefs set
*/

UMapDef( \mirror_point, { |point = #[0.0,0.0], plane = #[5.0,0.0], absolute = 0|
	var newX;
	point = point.asPoint;
	plane = plane.asPoint.asPolar;
	point = point.rotate( plane.theta.neg );
	newX = point.x.neg + (2 * plane.rho);
	newX = Select.kr( absolute, [ newX, newX.max( point.x ) ] );
	point = Point( newX, point.y ).rotate( plane.theta ); 
	UMapOut.kr(point.asArray, false);
})
	.setSpec( \point, WFSPointSpec(200,0.1) )
	.setSpec( \plane, WFSPlaneSpec(200,0.1) )
	.setSpec( \absolute, BoolSpec( false ) )
	.category_( 'point_utility' )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec );
	});
