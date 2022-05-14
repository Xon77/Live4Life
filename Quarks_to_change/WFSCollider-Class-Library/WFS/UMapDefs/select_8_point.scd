/*
\select_8_point

Creates an UMap that can select one from 8 points.

index: the index of the point (0-7)
interpolation: interpolation type (0:step, 1:linear) // cubic: todo
point0 - point7: the values of the steps (can be UMaps)

--
this is an UMapDef definition file
part of the Unit lib default UMapDefs set
*/

UMapDef( \select_8_point, {
	var points, interpolation;
	var index, sig;
	index = \index.kr(0);
	interpolation = \interpolation.kr(1.0);
	points = 8.collect({ |i|
		("point"++i).asSymbol.kr([0.0,0.0]);
	});
	sig = Select.kr( 
		interpolation,
		[
			Select.kr( index, points ),
			LinSelectX.kr( index, points )
		]
	);
	UMapOut.kr( sig, false );
}).category_( \point_utility )
	.setSpec( \interpolation, BoolSpec(true) )
	.setSpec( \index, [0,7].asSpec )
	.setSpec( \point0, WFSPointSpec(200, 0.1) )
	.setSpec( \point1, WFSPointSpec(200, 0.1) )
	.setSpec( \point2, WFSPointSpec(200, 0.1) )
	.setSpec( \point3, WFSPointSpec(200, 0.1) )
	.setSpec( \point4, WFSPointSpec(200, 0.1) )
	.setSpec( \point5, WFSPointSpec(200, 0.1) )
	.setSpec( \point6, WFSPointSpec(200, 0.1) )
	.setSpec( \point7, WFSPointSpec(200, 0.1) )