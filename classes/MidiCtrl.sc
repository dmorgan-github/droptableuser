Microlab {
    classvar <>ccChan=3, <>noteChan=3;
}

Roli {
    classvar <>noteChan=2, <>ccChan=2;
}


MidiCtrl {

    classvar <skipjack, <>frequency = 0.5;
	classvar <sources, <destinations;

    *trace {arg enable=true;
        MIDIFunc.trace(enable);
    }

    *start {
		if (skipjack.notNil) {
			skipjack.stop();
		};

		skipjack = SkipJack({ MidiCtrl.update }, { MidiCtrl.frequency }, name:'MidiCtrl');
	}

	*stop {
		skipjack.stop();
	}

    *update {

        // adapted from here: https://github.com/scztt/MIDIWatcher.quark/blob/master/MIDIWatcher.sc
        var oldSources, oldDestinations;
        oldSources = sources ?? { () };
        oldDestinations = destinations ?? { () };

        MIDIClient.list;

        sources = MIDIClient.sources.collectAs({ |e| e.asSymbol -> e }, IdentityDictionary);
        destinations = MIDIClient.destinations.collectAs({ |e| e.asSymbol -> e}, IdentityDictionary);

        oldSources.keys.difference(sources.keys).do {|removed|
            [\sourceRemoved, oldSources[removed]].postln;
            MIDIIn.disconnect(device:oldSources[removed])
        };
        oldDestinations.keys.difference(destinations.keys).do {|removed|
            [ \destinationRemoved, oldDestinations[removed] ].postln;
        };

        sources.keys.difference(oldSources.keys).do {|added|
            [ \sourceAdded, sources[added] ].postln;
            MIDIIn.connect(device:sources[added]);
        };
        destinations.keys.difference(oldDestinations.keys).do {|added|
            [ \destinationAdded, destinations[added] ].postln;
        };

	}

    *initClass {
        MIDIClient.init(verbose:true);
        sources = IdentityDictionary();
		destinations = IdentityDictionary();
	}
}

