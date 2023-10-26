+ Point {
	floor { ^this.copy.x_(this.x.floor).y_(this.y.floor) }

	ceil { ^this.copy.x_(this.x.ceil).y_(this.y.ceil) }
}