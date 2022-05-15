UnitSpherical : Spherical {

    *new { arg theta, phi;
        ^super.new(1, theta, phi)
    }

    rho_ { }

    asControlInput { ^[this.theta,this.phi] }

    printOn { arg stream;
		stream << "UnitSpherical( " <<  theta << ", " << phi << " )";
	}
	storeArgs { ^[theta,phi] }

	asUnitSpherical { ^this }

}

+ ArrayedCollection {

    asUnitSpherical {
        ^UnitSpherical(*this)
    }

}