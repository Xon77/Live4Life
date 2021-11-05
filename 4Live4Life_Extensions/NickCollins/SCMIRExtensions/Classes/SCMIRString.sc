+ String {
	
//old version 	
////add back in \ before any spaces
//asUnixPath {
////	var output = ""; 
////	var temp = this.split(32.asAscii);
////
////	temp.do{|str, i| 
////		
////		if(i<(temp.size-1)) {
////		
////		output = output++str++"\\ ";	
////		} {
////			
////		output = output++str;
////			
////		};	
////	};
////		
////	^output;
//	
//	^ (this.replace(" ","\\ ").replace("(","\\(").replace(")","\\)").replace("&","\\&").replace("!","\\!").replace("'","\\'"));
//}


	//Jonatan Liljedahl sc-dev 1 Feb
	asUnixPath {
		^"'"++this.replace("'","'\\''")++"'"
	}
	
}