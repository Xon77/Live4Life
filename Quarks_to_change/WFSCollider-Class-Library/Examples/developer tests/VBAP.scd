
//2D
(
//startup
Udef.defsFolders.add( 
			WFSArrayPan.filenameSymbol.asString.dirname +/+ "UnitDefs"
		);	
VBAPLib.startup;
VBAPSpeakerConf.default = VBAPSpeakerConf( (4.collect{ |i| (-45/2) - (45 * i) }  +++ 4.collect{ |i| (45/2) + (45 * i) }).flatten );
VBAPSpeakerConf.default.makeBuffer;
Udef.loadAllFromDefaultDirectory;
UMenuBar();
)

UChain(\blip, \vbap2D_Simple_Panner).gui
UChain(\blip, U(\wfsPathPlayer), U(\vbap2D_Panner).pointFromBus_(true)).gui

//3D
(
//startup
//Sonic Lab
x = [ [ 6.31, 0, -25.400967366 ], [ 6.34, 0, 25.9660516833 ], [ 6.67, 0, -67.0576274588 ], [ 6.57, 0, 66.6879780945 ], [ 6.45, 0, -107.4110491464 ], [ 6.46, 0, 107.3832377266 ], [ 7.64, 0, -146.2172414806 ], [ 7.65, 0, 146.1054525865 ], [ 9.6, 0, 0 ], [ 6.35, 0, 180 ], [ 9.22, 17.8750032812, -20.4495476108 ], [ 9.25, 17.8150833255, 20.571247071 ], [ 6.95, 24.0287030727, -65.6744247609 ], [ 6.98, 23.9189613576, 65.6416496995 ], [ 6.75, 24.7878302634, -108.1204280324 ], [ 6.72, 24.906009848, 108.1462414292 ], [ 7.06, 23.6313179834, -155.454155974 ], [ 7.08, 23.5605201117, 155.6036500106 ], [ 6.91, 52.7448792263, -27.5218854663 ], [ 6.9, 52.8541958285, 28.2311587404 ], [ 6.49, 57.9362142825, -74.594892688 ], [ 6.41, 59.0965878748, 73.451059145 ], [ 6.55, 57.1078901345, -113.1577815608 ], [ 6.6, 56.4426902381, 110.9030667368 ], [ 6.78, 54.2142657891, -151.3671810066 ], [ 6.9, 52.8541958285, 152.046597927 ], [ 6.0084357365, -50.4062940572, -28.0372821602 ], [ 6.0084357365, -50.4062940572, 28.0372821602 ], [ 5.8048083517, -52.9029151782, -77.6309384741 ], [ 5.7349280728, -53.8362268718, 77.1957339347 ], [ 5.9258332747, -51.38202567, -116.4957697362 ], [ 5.9035836574, -51.6531568981, 116.7749248886 ], [ 6.0235952719, -50.2322714936, -159.9660768355 ], [ 6.0655832366, -49.7580403359, 157.4926118991 ] ]; 
y = x.flop[1..].swap(0,1).flop;
z = x.collect(_[0]);

~sonicLab = VBAPSpeakerConf(y,z);
Udef.defsFolders.add( 
			WFSArrayPan.filenameSymbol.asString.dirname +/+ "UnitDefs"
		);	
VBAPLib.startup;
VBAPSpeakerConf.default = ~sonicLab;
VBAPSpeakerConf.default.makeBuffer;
Udef.loadAllFromDefaultDirectory;
UMenuBar();
)

UChain(\blip, \vbap3D_Simple_Panner).gui;
UChain(\blip, \vbap3D_Panner).gui