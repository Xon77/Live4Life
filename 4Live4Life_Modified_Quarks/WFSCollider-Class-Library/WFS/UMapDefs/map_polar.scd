/*
\map_polar

Creates an UMap intended for use on modulatable point parameters. It converts the point into a polar, with linear controls for rho and theta, which on their turn can be used to assign other UMaps to. The point is mapped to a circle or ellipse with settable center and radius.

rho: the rho value (0-1)
theta: the theta value (angle in radians)
center: center of the mapped area
radius: radius of the mapped area

--
this is an UMapDef definition file
part of the Unit lib default UMapDefs set
*/

UMapDef( \map_polar, { |
		rho = 0.0, 
		theta = 0, 
		center = #[0.0,0.0],
		radius = #[10.0,10.0]|
	var polar;
	polar = Polar( rho, theta );
	x = polar.real;
	y = polar.imag;
	UMapOut.kr([polar.real, polar.imag] * radius + center, false );
})
	.setSpec( \theta, AngleSpec() )
	.setSpec( \rho, [-1,1,\lin,0,0].asSpec )
	.setSpec( \center, WFSPointSpec(200) )
	.setSpec( \radius, WFSRadiusSpec(200) )
	.category_( 'point_utility' )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec );
	});
