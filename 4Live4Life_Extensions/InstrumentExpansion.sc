// http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/Pchain-Pnsym1-with-arrays-td7621527.html

// from James Harkins

PexpandInstr : FilterPattern {
    embedInStream { |inval|
        var stream = pattern.asStream,
        next, partial;
        while {
            next = stream.next(inval);
            next.notNil
        } {
            if(next[\instrument].size == 0) {
                next.yield;
            } {
                next[\instrument].do { |instr, i|
                    partial = next.collect({ |value|
                        if(value.isSequenceableCollection) {
                            value.wrapAt(i)
                        } {
                            value
                        }
                    }).put(\instrument, instr);
                    if(i < (next[\instrument].size - 1)) {
                        partial.put(\delta, 0);
                    };
                    inval = partial.yield;
                };
            };
        };
        inval
    }
}

// from Daniel Mayer

PchainT : Pattern {
        var <>eventPattern, <>eventListPattern;
        *new { |eventPattern, eventListPattern|
                ^super.newCopyArgs(eventPattern, eventListPattern);
        }
        embedInStream { arg inval;
                var eventStream, eventListStream, inevent, nextEvent, nextEventList,
                        outEventList, cleanup = EventStreamCleanup.new;

                eventStream = eventPattern.asStream;
                eventListStream = eventListPattern.asStream;
                loop {
                        inevent = inval.copy;
                        nextEventList = eventListStream.next(());
                        nextEvent = eventStream.next(());
                        outEventList = nextEventList.collect { |ev, i|
                                if(inevent.isNil) { ^cleanup.exit(inval) };
                                inevent = inevent.composeEvents(ev);
                                if(inevent.isNil) { ^cleanup.exit(inval) };
                                inevent = inevent.composeEvents(nextEvent);
                                if(inevent.isNil) { ^cleanup.exit(inval) };
                                inevent
                        };
                        cleanup.update(inevent);
                        inval = yield(outEventList);
                };
        }
}

// we need playAndDelta for event lists
// important assumption: dur is equal for all events of a list !!

+SequenceableCollection {
        playAndDelta { | cleanup, mute |
                if (mute) { this.put(\type, \rest) };
//	cleanup.update(this);
                this.do { |x| x.play };
                ^this.first.delta;
        }
}