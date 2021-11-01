AudioDeviceSpec : Spec { 
	
	classvar <devices;
	
	var default;
	
	*initClass {
		devices = [];
		//StartUp.defer({ this.refreshDevices; });
	}
	
	*new { |default, addDevices|
		this.addDevices( [ default ] ++ addDevices );
		^super.newCopyArgs(default);
	}
	
	*addDevices { |addDevices|
		var added = false;
		addDevices.do({ |item|
			if( item.notNil && { devices.any({ |device| item == device }).not } ) {
				devices = devices.add( item );
				added = true;
			};
		});
		if( added ) { this.devices = devices };
	}
	
	*devices_ { |newDevices|
		devices = newDevices;
		this.changed( \devices );
	}
	
	*refreshDevices { 
		this.addDevices( 
			ServerOptions.devices.select({ |item|
				item.find( "Built-in", true ).isNil
			})
		); 
	}
	
	map { |in| ^in }
	unmap { |in| ^in }
	
	constrain { |device|
		if( device.notNil && { ServerOptions.devices.any({ |item| item == device }).not }) {
			"AudioDeviceSpec:constrain - device '%' does not exist on this machine.\n\tThe server will use the system default device instead\n"
				.postf( device )
		};
		this.class.addDevices( [ device ] );
		^device;
	}
	
	makeView { |parent, bounds, label, action, resize|
		var multipleActions = action.size > 0;
		var vw;
		var ctrl;
		var fillPopUp;
		this.class.refreshDevices;
		vw = EZPopUpMenu( parent, bounds, label !? { label.asString ++ " " });
		fillPopUp = {
			vw.items = [
				'system default' -> { |vw| action.value( vw, nil ) }
			] ++ devices.collect({ |device|
				device.asSymbol -> { |vw| action.value( vw, device ) }
			}) ++ [
			     '' -> { },
				'add...' -> { |vw| 
					SCRequestString( "", "please enter device name:", { |string|
						action.value( vw, this.constrain( string ) );
					})
				}
			];
		};
		fillPopUp.value;
		ctrl = SimpleController( this.class )
			.put( \devices, {
				{ fillPopUp.value }.defer;
			});
		vw.onClose_({ ctrl.remove });
		vw.labelWidth = 80; // same as EZSlider
		vw.applySkin( RoundView.skin ); // compat with smooth views
		if( resize.notNil ) { vw.view.resize = resize };
		^vw
	}
	
	setView { |view, value, active = false|
		{  // can call from fork
			value = this.constrain( value );
			view.value = view.items.collect(_.key).indexOf( value.asSymbol ) ? 0;
			if( active ) { view.doAction };
		}.defer;
	}
	
	mapSetView { |view, value, active = false|
		{  // can call from fork
			view.value = view.items.collect(_.key).indexOf( value.asSymbol ) ? 0;
			if( active ) { view.doAction };
		}.defer;
	}

	
}