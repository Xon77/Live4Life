
+ Object {
	writeSCMIRZArchive { arg akv;
		var thing;
		thing = this.asCompileString;
		if(thing.size > 127,{
			akv.putChar($X);
			akv.writeLargeString( thing );
		} , {
			akv.putChar($x);
			akv.writeString( thing );
		})
	}
	// this.new, then new.readSCMIRZArchive
	*readSCMIRZArchive { arg ... args;
		var new,akv;
		new = this.new;
		akv = args.first;
		if(akv.isString,{
			akv = SCMIRZArchive.read(Document.standardizePath(akv));
			args[0] = akv;
		 });
		new.performList(\readSCMIRZArchive,args);
		^new
	}
	// see Help file
	readSCMIRZArchive { /*arg akv; ^akv.readItem;*/ }
}

+ Nil {
	writeSCMIRZArchive { arg akv;
		akv.putChar($N);
	}
}

+ String {
	asSCMIRZArchive {
		^SCMIRZArchive.write(Document.standardizePath(this))
	}
	writeSCMIRZArchive { arg akv;
		if(this.size < 128,{
			akv.putChar($s);
			akv.writeString(this);
			^this
		},{	// up to 4294967296
			akv.putChar($S);
			akv.writeLargeString(this);
		});
	}
}
+ Symbol {
	writeSCMIRZArchive { arg akv;
		akv.putChar($y);
		akv.writeString(this.asString);
	}
}

+ Float {
	writeSCMIRZArchive { arg akv;
		akv.putChar($F);
		akv.putFloat(this);
	}
}
+ Integer {
	writeSCMIRZArchive { arg akv;
		akv.putChar($I);
		akv.putInt32(this);
	}
}

/* raw arrays could cut in half by not having to repeat the class
		if(this.isKindOf(RawArray),{ // check the type of this.at(0)
			akv.putChar($S);
			classname = this.class.name.asString;
			akv.putInt8(classname.size);
			akv.putString(classname);
			akv.putInt32(this.size);
			akv.write(this); // do ?
		}
*/

// classname is written, so you will get the correct class back
+ Dictionary {
	writeSCMIRZArchive { arg akv;
		var classname;
		akv.putChar($D);
		classname = this.class.name.asString;
		akv.writeString(classname);
		akv.putInt32(this.size);
		this.keysValuesDo({ arg k,v,i;
			akv.writeItem(k);
			akv.writeItem(v)
		});
	}
}

+ SequenceableCollection {
	writeSCMIRZArchive { arg akv;
		var classname;
		akv.putChar($C);
		classname = this.class.name.asString;
		akv.writeString(classname);
		akv.putInt32(this.size);
		this.do({ arg it; akv.writeItem(it) });
	}
}
