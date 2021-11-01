+ Pen {
	*strokeImgArc { |center, radius, startAngle, arcAngle, segs, img, ip1, ip2, width = 1|
		var ip, inc = arcAngle / segs;

		unless (ip1.x.inRange(0, img.width - 1) or: ip1.y.inRange(0, img.height - 1)) {
			"First image sourcing point out of bounds.".error;
			^this;
		};

		unless (ip2.x.inRange(0, img.width - 1) or: ip2.y.inRange(0, img.height - 1)) {
			"Second image sourcing point out of bounds.".error;
			^this;
		};

		(startAngle + (0, inc .. (segs - 1) * inc)).do { |theta|
			ip = ip2 - ip1;
			this.strokeColor_(img.getColor(
				ip1.x + (ip.x * (theta + inc).linlin(0, segs * inc, 0.0, 1.0)),
				ip1.y + (ip.y * (theta + inc).linlin(0, segs * inc, 0.0, 1.0))));
			this.width_(width);
			this.addArc(center, radius, theta, inc).stroke;
		};
	}

	*strokeImgCircle { |center, radius, segs, img, ip1, ip2, width = 1|
		this.strokeImgArc(center, radius, 0, 2pi, segs, img, ip1, ip2, width);
	}

	*strokeImgLine { |p1, p2, segs, img, ip1, ip2, width = 1|
		var ip, dy = (p2.y - p1.y) / segs, dx = (p2.x - p1.x) / segs;

		unless (ip1.x.inRange(0, img.width - 1) or: ip1.y.inRange(0, img.height - 1)) {
			"First image sourcing point out of bounds.".error;
			^this;
		};

		unless (ip2.x.inRange(0, img.width - 1) or: ip2.y.inRange(0, img.height - 1)) {
			"Second image sourcing point out of bounds.".error;
			^this;
		};

		(p1.x, p1.x + dx .. p2.x - dx).do { |x|
			ip = ip2 - ip1;
			this.strokeColor_(img.getColor(
				ip1.x + (ip.x * (x + dx).linlin(0, segs * dx, 0.0, 1.0)),
				ip1.y + (ip.y * (x + dx).linlin(0, segs * dx, 0.0, 1.0))));
			this.width_(width);
			this.line(
				Point.new(x, x.linlin(p1.x, p2.x, p1.y, p2.y)),
				Point.new(x + dx, (x + dx).linlin(p1.x, p2.x, p1.y, p2.y))).stroke;
		};
	}

	*addParametric { |center, xfunc, yfunc, t1, t2, segs|
		var dt = t2 / segs;
		(t1, t1 + dt .. t2 - dt).do { |t|
			this.line(
				Point.new(center.x + xfunc.(t), center.y + yfunc.(t)),
				Point.new(center.x + xfunc.(t + dt), center.y + yfunc.(t + dt)));
		};
	}

	*strokeParametric { |center, xfunc, yfunc, colorfunc, t1, t2, segs|
		var dt = t2 / segs;
		(t1, t1 + dt .. t2 - dt).do { |t|
			this.strokeColor_(colorfunc.(t));
			this.line(
				Point.new(center.x + xfunc.(t), center.y + yfunc.(t)),
				Point.new(center.x + xfunc.(t + dt), center.y + yfunc.(t + dt)));
			this.stroke;
		};
	}

	*strokeImgParametric { |center, xfunc, yfunc, t1, t2, img, ip1, ip2, segs|
		var dt = t2 / segs, ip, tmax = t2 - t1;

		unless (ip1.x.inRange(0, img.width - 1) or: ip1.y.inRange(0, img.height - 1)) {
			"First image sourcing point out of bounds.".error;
			^this;
		};

		unless (ip2.x.inRange(0, img.width - 1) or: ip2.y.inRange(0, img.height - 1)) {
			"Second image sourcing point out of bounds.".error;
			^this;
		};

		(t1, t1 + dt .. t2 - dt).do { |t|
			ip = ip2 - ip1;
			this.strokeColor_(img.getColor(
				ip1.x + (ip.x * (t / tmax)),
				ip1.y + (ip.y * (t / tmax))));
			this.line(
				Point.new(center.x + xfunc.(t), center.y + yfunc.(t)),
				Point.new(center.x + xfunc.(t + dt), center.y + yfunc.(t + dt)));
			this.stroke;
		};
	}

	*addPolarLine { |center, rho, theta, rho0 = 0|
		this.line(
			center + Polar.new(rho0, theta),
			center + Polar.new(rho + rho0, theta));
	}

	*addCircle { |center, radius|
		if (radius < 0) { "Radius less than zero.".error; ^this };
		this.addArc(center, radius, 0, 2pi);
	}

	*addSquare { |center, size|
		if (size < 0) { "Size less than zero.".error; ^this };
		this.addRect(
			Rect.new(center.x - (size / 2), center.y - (size / 2), size, size));
	}

	*addPixel { |x, y| this.line(Point.new(x + 0.5, y), Point.new(x + 0.5, y + 1)) }
}
