USharedPointIn : USharedValueIn {
	
	classvar <>busOffset = 1200;
	
	*spec { |default| ^SharedPointIDSpec( default ) }
	
	*kr { |id, default = 0|
		^In.kr( (this.makeInput( id, default ) * 2) + this.busOffset + [0,1] );
	}
}

USharedPointOut : USharedPointIn {

	*kr { |id, channelsArray, default = 0|
		id = this.makeInput( id, default ) * 2;
		channelsArray = channelsArray.asArray;
		^[
			ReplaceOut.kr( id + this.busOffset, channelsArray[0] ),
			ReplaceOut.kr( id + this.busOffset + 1, channelsArray[1] )
		]
	}
}