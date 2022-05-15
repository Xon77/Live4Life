/*
\point_in_rect

Creates an UMap for testing if a point is inside or outside a rectangle.

point: the point
center: the center of the rect area
radius: the radius of the rect area
inValue: the value to return when the point is inside the rect
outValue: the value to return when the point is outside the rect

The 'inValue' and 'outValue' arg range is mapped to that of the parameter to which the UMap is connected.

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

UMapDef( \point_in_rect, { |
		point = #[0.0, 0.0], 
		center = #[0.0, 0.0], 
		radius = #[10.0, 10.0], 
		inValue = 1.0,
		outValue = 0.0|
	var index, output;
	var rangeX, rangeY;
	rangeX = center[0] + (radius[0] * [-1,1]);
	rangeY = center[1] + (radius[1] * [-1,1]);
	index = InRange.kr( point[0], *rangeX ) * InRange.kr( point[1], *rangeY );
	output = Select.kr( index, [ outValue, inValue ] );
	UMapOut.kr( output );
})
	.setSpec( \point, WFSPointSpec(200) )
	.setSpec( \center, WFSPointSpec(200) )
	.setSpec( \radius, WFSRadiusSpec(Rect(0,0,200,200)) )
	.mappedArgs_([ \inValue, \outValue ])
	.category_( 'point_to_value' );