AbstractWFSOptions {
	
	classvar <>usePresetsForCS = false;
	classvar <>makeCurrentAtInit = false;
	
	*fromPreset { |name| ^this.presets[ name ].deepCopy; }
	
	== { |that| // use === for identity
		^this.compareObject(that);
	}
	
	doesNotUnderstand { |selector, arg1 ...args|
		// MVC support for all args that have no setters
		if( selector.isSetter ) {
			selector = selector.asGetter;
			if( this.class.instVarNames.includes( selector ) ) {
				this.slotPut( selector, arg1 );
				this.changed( selector, arg1 );
			};
		};
	}
	
	fromObject { |obj|
		 this.class.instVarNames.do({ |varname|
			 this.perform( varname.asSetter, obj.perform( varname ).deepCopy );
		 });
	}
	
	matchPreset {
		^this.class.presets.findKeyForValue(this);
	}
	
	storeOn { arg stream;
		stream << this.class.name;
		this.storeModifiersOn(stream);
	}
	
	storeModifiersOn { |stream|
		var preset;
		preset = this.matchPreset;
		if( usePresetsForCS && { preset.notNil } ) {
			stream << ".fromPreset(" <<< preset << ")";
		} {	
			stream << "()";
			this.class.instVarNames.do({ |item, i|
				if( this.perform( item ) != this.class.iprototype[i] ) {
					stream << "\n\t." << item << "_(" <<< this.perform( item ) << ")";
				};
			});
		}
	}
	
}

WFSMasterOptions : AbstractWFSOptions {

	var <toServersBus = 14;
	var <numOutputBusChannels = 20;
	var <numInputBusChannels = 20;
	var <outputBusStartOffset = 0;
	var <device;
	var <hardwareBufferSize = 512;
	var <useForWFS = false;
	
	*presets { ^Dictionary[] }
		
}

WFSServerOptions : AbstractWFSOptions {
	
	classvar <>presets;
	
	var <name = "Game Of Life 1";
	var <ip = "127.0.0.1";
	var <startPort = 58000;
	var <n = 8;
	var <numOutputBusChannels = 96;
	var <numInputBusChannels = 8;
	var <outputBusStartOffset = 0;
	var <device = "JackRouter";
	var <hardwareBufferSize = 512;
	
	
	*initClass {
		presets = Dictionary[
			'game_of_life_1'-> WFSServerOptions()
				.name_( "Game Of Life 1" )
				.ip_( "192.168.2.11" ),
			'game_of_life_2'-> WFSServerOptions()
				.name_( "Game Of Life 2" )
				.ip_( "192.168.2.12" ),
			'bea7'-> WFSServerOptions()
				.name_( "WFSBea7" )
				.ip_( "127.0.0.1" )
				.n_( 6 )
				.numOutputBusChannels_( 120 )
				.numInputBusChannels_( 72 )
				.device_( nil ), // ?
			'sampl'-> WFSServerOptions()
				.name_( "SamPL WFS" )
				.ip_( "127.0.0.1" )
				.n_( 4 )
				.numOutputBusChannels_( 32 )
				.numInputBusChannels_( 32 )
				.device_( "PreSonus FireStudio" ),
		];	
	}
	
	useForWFS { ^true }
	
}

WFSOptions : AbstractWFSOptions {
	
	classvar <>current;
	classvar <>presetManager;
	
	var <masterOptions;
	var <serverOptions = #[];
	var <showGUI = true;
	var <showServerWindow = true;
	var <previewMode = \off;
	var <playSoundWhenReady = false;
	var <startupAction;
	var <serverAction;
	var <blockSize = 128;
	var <sampleRate = 44100;
	var <wfsSoundFilesLocation = "/WFSSoundFiles";
	
	*new { ^super.new.init; }
	
	init {
		if( makeCurrentAtInit ) { this.makeCurrent; };
	}
	
	makeCurrent {
		current = this;
	}
	
	*presets { ^presetManager.presets.as(IdentityDictionary) }
	
	*fromPreset { |name| ^presetManager.apply( name ).makeCurrent }
	
	fromPreset { |name| ^presetManager.apply( name, this ); }
	
	matchPreset {
		^presetManager.match(this);
	}
	
	*initClass {
		Class.initClassTree( WFSServerOptions );
		Class.initClassTree( PresetManager );
		presetManager = PresetManager( WFSOptions );
		presetManager.applyFunc_( { |object, preset|
			 	if( object === WFSOptions ) {
				 	preset.deepCopy;
			 	} {	
				 	object.fromObject( preset );
				}
		 	} );
		 	
		presetManager.presets = [
			'default', WFSOptions() // offline
				.masterOptions_(
					WFSMasterOptions()
						.useForWFS_(true)
				)
				.previewMode_( \headphone ),
			'game_of_life_master', WFSOptions()
				.masterOptions_(
					WFSMasterOptions()
						.toServersBus_(14)
						.numOutputBusChannels_(20)
						.device_( "MOTU 828mk2" )					)
				.serverOptions_([	
					WFSServerOptions.fromPreset( 'game_of_life_1' ),
					WFSServerOptions.fromPreset( 'game_of_life_2' )
				]),
			'game_of_life_server', WFSOptions()
				.serverOptions_([	
					WFSServerOptions()
				])
				.showGUI_( false )
				.playSoundWhenReady_( true ),
			'bea7_client',  WFSOptions()
				.serverOptions_([	
					WFSServerOptions.fromPreset( 'bea7' )
						.ip_( "10.20.1.2" )
				])
				.serverAction_({ |server|
	{
		Synth.tail( server, \wfsToAuxSpeakers ); 
	}.defer(0.1);
}),
			'bea7_server',  WFSOptions()
				.serverOptions_([	
					WFSServerOptions.fromPreset( 'bea7' )
				])
				.showGUI_( false )
				.showServerWindow_( false )
				.startupAction_({				
	var numSpeakers = 112;
	var speakerIndexes = [54, 81, 24, 111, 67, 11, 39, 96];
	var lpf = 200, hp = 6000;
	var delays = [ 1, 0.84, 1, 0.93, 0, 0, 0.9, 0.9 ] / 1000;

	SynthDef(\wfsToAuxSpeakers,{ 
		var out = In.ar(speakerIndexes,1);
		out = BLowPass.ar(out, lpf) + BHiPass.ar(out, hp);
		out = DelayL.ar(out, delays, delays);
		ReplaceOut.ar(numSpeakers, out)
	}).writeDefFile;
}),
			'sampl', WFSOptions()
				.serverOptions_([
					WFSServerOptions.fromPreset( 'sampl' )
				]),
			'parma', WFSOptions()
				.serverOptions_([ WFSServerOptions()
				.name_("Parma WFS")
				.n_(6)
				.numOutputBusChannels_(189)
				.numInputBusChannels_(32)
				.device_(nil) ]),
			'test_sync', WFSOptions()
				.masterOptions_(
					WFSMasterOptions()
						.toServersBus_(0)
						.device_("JackRouter")
				)
				.serverOptions_([ 
					WFSServerOptions()
					.n_(4) ])
				.playSoundWhenReady_(true)
				.serverAction_({ |srv|
var i;
// this requires jackosx to be running
i = srv.name.asString.last;
"/usr/local/bin/jack_disconnect system:capture_1 scsynth-0%:in1".format(i).unixCmd;
"/usr/local/bin/jack_connect scsynth:out1 scsynth-0%:in1".format(i).unixCmd;
})
];
		
		current = nil;
	}	
}