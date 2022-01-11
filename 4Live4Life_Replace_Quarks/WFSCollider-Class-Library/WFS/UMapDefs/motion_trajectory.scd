/*
\motion_trajectory

Creates an UMap for generating a motion based on speed and acceleration, contained in a rectangular area.

startPoint: start point of the movement, can be changed over time
startSpeed: initial speed, can be changed over time to produce relative speed changes
acceleration: (in m/s^2) amount of acceleration over x and y axes
center: the center of the clipping area
radius: the radius of the clipping area
clipMode: can be one of the following modes:
	0 - 'clip': clip coordinates outside clipping area
	1 - 'fold' (default): fold/mirror coordinates outside clipping area - this produces a typical hard wall bounce
	2 - 'wrap': wrap around coordinates outside clipping area
	3 - 'none': no clipping applied (values can go outside  clipping area)
clipSoftness: softens the edges of 'clip' and 'fold' modes.
reset: jump to startPoint/startSpeed

note: There may be floating precision issues when running this for a very long time.

--
this is an UMapDef definition file
part of the Unit lib default UMapDefs set
*/


UMapDef( \motion_trajectory, { |
		startPoint = #[0.0, 0.0],
		startSpeed = #[1.0, 1.0],
		acceleration = #[0.0, 0.0], 
		center = #[0.0, 0.0], 
		radius = #[10.0, 10.0], 
		clipMode = 1,
		clipSoftness = 0.1|
	var point, speed;
	var reset;
	reset = \reset.utr + Impulse.kr(0);
	radius = radius.max(1.0e-10);
	
	speed = Sweep.kr( reset, acceleration ) + startSpeed;
	point = Sweep.kr( reset, speed ) + startPoint;

	point = point - center;
	point = point.linlin( radius.neg, radius, -1, 1, \none );
	point = Select.kr( clipMode, [
		point.softclip2(1, clipSoftness),
		point.softfold2(1, clipSoftness),
		point.wrap2(1),
		point
	]);
	point = point.linlin( -1, 1, radius.neg, radius, \none ) + center;
	UMapOut.kr(point, false);
})
	.setSpec( \startPoint, WFSPointSpec(200) )
	.setSpec( \startSpeed, WFSPointSpec(200) )
	.setSpec( \acceleration, WFSPointSpec(200) )
	.setSpec( \center, WFSPointSpec(200) )
	.setSpec( \radius, WFSRadiusSpec(Rect(0,0,200,200)) )
	.setSpec( \clipMode, ListSpec( (..3), 1, [ \clip, \fold, \wrap, \none ] ) )
	.setSpec( \clipSoftness, [0,1,\lin,0,0.1].asSpec )
	.category_( 'point_trajectory' )
	.canUseUMapFunc_({ |unit, key, umapdef|
		unit.getSpec( key ).isKindOf( PointSpec );
	})