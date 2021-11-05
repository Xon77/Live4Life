+ KMeans {
	
save {|filename|
		var a;       
		  
		filename = filename?? {SCMIR.tempdir++"KMeans"++".scmirZ"};     
		  
		a = SCMIRZArchive.write(filename);      
		  
		a.writeItem(k);    
		a.writeItem(data);      
		a.writeItem(centroids);   
		a.writeItem(assignments);   
		  
		a.writeClose;  
	
}


load {|filename| 
	
		var a;       
		  
		filename = filename?? {SCMIR.tempdir++"KMeans"++".scmirZ"};        
		  
		a = SCMIRZArchive.read(filename);      
		  
		k = a.readItem;       
		data = a.readItem;       
		centroids = a.readItem;   
		assignments = a.readItem;   
		  
		a.close;      
	
}		
	
}