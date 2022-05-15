(
// a position-dependant reverb scheme
var points;
points = [-6,6].collect({ |x| [-6,6].collect(x@_) }).flat;

UnitRack(\wfsSimpleReverb, [	
		\shared_point,
		[ \multiply, [ 
			'mul', [ 'point_distance', [ 
				'point1', 'shared_point_in', 
				'fromRange', [ 0.0, 15 ], 
				'toRange', [ 0.0, 0.5 ] ] 
			], 
			'u_o_ar_0_bus', 1
		] ],
		[ 'delay', [ 
			'time', [ 'point_distance', [ 
				'point1', 'shared_point_in', 
				'fromRange', [ 0.0, 10.0 ], 
				'toRange', [ 0.0, 0.29 ], 
				'clipMode', 3 ] 
			], 'timeScale', 0.1, 'dry', 0.0, 'amp', 1.0, 
			'u_i_ar_0_bus', 1, 'u_o_ar_0_bus', 1 
		] ], 
		[ 'duplicateChannel', [ 'u_i_ar_0_bus', 1, 'numChannels', 4 ] ++
			4.collect({ |i| [ "u_o_ar_%_bus".format(i).asSymbol, i+1 ] }).flat
		],
	] ++ 4.collect({ |i| 
		U( \freeverb, [ 
			'mix', 1.0, 'room', i.linlin(0,3,0.47,0.53), 'damp', [ 
				'point_distance', [ 
					'point1', 'shared_point_in', 
					'fromRange', [ 0.0, 8.0 ] 
				] ], 'u_i_ar_0_bus', i+1, 'u_o_ar_0_bus', i+1 
			] 
		)
	}) ++ points.collect({ |pt,i| 
		U( 'wfsSource', [ 'point', pt, 'type', 'plane', 'u_i_ar_0_bus', i+1 ] )
	}) ++ [ 
		[ 'wfsSource', [ 'point', 'shared_point_in' ] ] 
	]
).category_( \wfs );
)