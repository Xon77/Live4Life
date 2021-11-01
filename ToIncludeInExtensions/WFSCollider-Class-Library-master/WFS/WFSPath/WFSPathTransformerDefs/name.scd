WFSPathTransformerDef( \name, 
	{ |f, obj| obj.name_( f.get( \name ) ) }, 
	[ \name, "" ], 
	{ |f, obj| [ \name, obj.name ] } 
)	.setSpec( \name, StringSpec() )
	.useSelection_( false );
		