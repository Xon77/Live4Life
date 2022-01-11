VBAPDistComp1 {

    *make{ arg rate = \ar, numChans, in, bufnum, azimuth = 0.0, elevation = 1.0, spread = 0.0, distances;
        var c = Number.speedOfSound(20);
        var maxDistance = distances.maxItem;
        var delayTimes = distances.collect{ |d| (maxDistance-d) / c  };
        var out = VBAP.perform(rate, numChans, in, bufnum, azimuth, elevation, spread);
        if( numChans != distances.size) {
            Error( "VBAP: Distance array and number of outputs mismatch." ).throw
        };
        ^DelayN.perform(rate, out, maxDistance / c, delayTimes )
    }

	*ar { arg numChans, in, bufnum, azimuth = 0.0, elevation = 1.0, spread = 0.0, distances;
	    ^this.make(\ar, numChans, in, bufnum, azimuth, elevation, spread, distances)
	}

	*kr { arg numChans, in, bufnum, azimuth = 0.0, elevation = 1.0, spread = 0.0, distances;
	    ^this.make(\ar, numChans, in, bufnum, azimuth, elevation, spread, distances)
	}

}

VBAPDistComp2 {

    *delayTimes { |distances|
        var c = Number.speedOfSound(20);
        var maxDistance = distances.maxItem;
        ^distances.collect{ |d| (maxDistance-d) / c  };
    }

    *make{ arg rate = \ar, numChans, in, bufnum, azimuth = 0.0, elevation = 1.0, spread = 0.0, delays;
        var out = VBAP.perform(rate, numChans, in, bufnum, azimuth, elevation, spread);
        if( numChans != delays.size) {
            Error( "VBAP: Delay array and number of outputs mismatch." ).throw
        };
        ^DelayN.perform(rate, out, 0.2, delays )
    }

	*ar { arg numChans, in, bufnum, azimuth = 0.0, elevation = 1.0, spread = 0.0, delays;
	    ^this.make(\ar, numChans, in, bufnum, azimuth, elevation, spread, delays)
	}

	*kr { arg numChans, in, bufnum, azimuth = 0.0, elevation = 1.0, spread = 0.0, delays;
	    ^this.make(\ar, numChans, in, bufnum, azimuth, elevation, spread, delays)
	}

}