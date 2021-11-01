
//algorithm described here:
//http://blogs.msdn.com/b/devdev/archive/2005/09/01/459540.aspx



(

n = 3;
p = n.collect{ |i| (0@1).rotate(2pi*i/n) };
~point = 0.5@0.5;
w = ScaledUserView.window( "WFSSpeakerConf", 
	Rect( 128, 64, 400, 400 ), 
	Rect.aboutPoint( 0@0, 2, 2 );
);
w.keepRatio = true;
w.drawFunc = { 
	var fader, crossfades, lines;
	Pen.addArc( ~point.asPoint * (1 @ -1), 0.1/2, 0, 2pi ).fill; 
	
	// draw corns as blue points
	
	// vector connecting edge k to edge k-1
	~vecs = p.size.collect{ |i| p[i] - p[(i-1).wrap(0,p.size-1)] };
	//vector connecting edge k to point
	~vecs2 = p.collect{ |x| ~point - x };
	// if crossproducts of vector connecting edge k-1 to k and vector connecting edge k to point 
	// have all the same sign then it's inside.
	if( ~vecs.collect{ |v,i| ((v.x*~vecs2[i].y)-(v.y*~vecs2[i].x)).isPositive }.asSet.size < 2) {
		Pen.color = Color.blue;
	} {
		Pen.color = Color.red;
	};
	p.do({ |pt|
		Pen.addArc( pt.asPoint * (1 @ -1), 0.1/2, 0, 2pi ).fill; 
	});
	


};
w.scale = 1;
w.mouseDownAction = { |v, x,y| ~point = (x @ y.neg); };
w.mouseMoveAction = { |v, x,y| ~point = (x @ y.neg); };
)

// a more weird convex polygon
p = [0@0, 1@0, 1@1, 0.5@1.7, -0.2@1, -0.5@0.5]