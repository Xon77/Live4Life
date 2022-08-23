+ SequenceableCollection {
	isNondecreasing { ^ltEq(*this) }

	isNonincreasing { ^gtEq(*this) }

	isMonotonicallyIncreasing { ^lt(*this) }

	isMonotonicallyDecreasing { ^gt(*this) }
}