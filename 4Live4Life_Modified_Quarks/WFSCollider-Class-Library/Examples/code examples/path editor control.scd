// WFSPathGUI is a plotting and editing view for WFSPath2 objects

a = WFSPathGUI();

// modify zoom settings
a.zoomToFit;
a.zoom( 2 );
a.zoom; // reset
a.move(-1,10);
a.move; // reset

// selection from code
a.select( 1, 2, 6 );
a.selectAll;
a.selectNone;

// edit from code (can also do by mouse)
a.moveSelected( 2, -2, ModKey(0) );
a.scaleSelected( 0.5, -0.75 );
a.rotateSelected( 0.125pi, 1.25 ); // rotate and scale

// mouse modes
a.mouseMode = \select; // default, also edit
a.mouseMode = \zoom; // zoom in/out, double-click for zoomToFit
a.mouseMode = \move; // move canvas, double-click for centered
a.mouseMode = \record; // record a path (resets to \select after mouseUp)

// mouse edit modes
// these only work when mouseMode == \select
a.editMode = \move;
a.editMode = \scale;
a.editMode = \rotate;
a.editMode = \rotateS;
a.editMode = \elastic;
a.editMode = \lock; // editing disabled


// position display and animation
a.pos = 0.25; // show time position
a.pos = nil;

a.animate( true ); // animation
a.animate( false );

a.animationRate = 0.25; // slow down
a.animationRate = 1; // normal speed

// undo
a.undo; // go to previous state
a.undo(-1); // go to next state (if available)


