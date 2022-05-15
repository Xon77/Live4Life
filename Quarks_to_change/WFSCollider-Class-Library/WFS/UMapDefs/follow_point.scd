/*
\follow_point

Creates an UMap for applying speed and rotation limits to a point input.

point: the point to follow
maxSpeed: maximum speed in m/s
maxRotation: maximum rotation in deg/s

--
this is an UMapDef definition file
part of the WFSCollider Class Library default UMapDefs set
*/

UMapDef( \follow_point, { |
		point = #[0.0, 0.0], 
		maxSpeed = 1,
		maxRotation = 180
		|
	var fp, initPoint, delta, angle, x, y;
	maxSpeed = maxSpeed * ControlDur.ir;
	maxRotation =  maxRotation * (1/180pi);
	initPoint = DC.kr( point );
	#x,y,angle = LocalIn.ar(3);
	fp = initPoint + [x,y];
	delta = (point - fp).asPoint.asPolar;
	delta.rho = delta.rho.min( maxSpeed );
	delta.theta = if( delta.rho < maxSpeed, 
		delta.theta, 
		(delta.theta - angle).wrap2( pi ).clip2( maxRotation ) + angle 
	);
	angle = if( delta.rho > 0, delta.theta, angle );
	delta = delta.asPoint.asArray;
	fp = fp + delta;
	LocalOut.ar( (fp - initPoint) ++ [ angle ] );
	UMapOut.kr(fp, false);
})
	.setSpec( \point, WFSPointSpec(200, 0.1) )
	.setSpec( \maxSpeed, [0,344,8].asSpec )
	.setSpec( \maxRotation, [0,180,\lin].asSpec )
	.category_( 'point_filter' )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec );
	})