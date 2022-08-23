+ CtkProtoNotes {
	printOn { |stream|
		stream << "CtkProtoNotes" << this.synthdefs.collect(_.asDefName).asString << Char.nl;
	}
}