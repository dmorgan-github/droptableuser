Microlab {
    classvar <>ccChan=3, <>noteChan=3;
}

Roli {
    classvar <>noteChan=2, <>ccChan=2;
}


MidiCtrl {

    classvar <skipjack, <>frequency = 0.5;
	classvar <sources, <destinations;
    var <synth;

    *new {|synth|
        super.new.prInit(synth);
    }

    // TODO: possibly move the midi stuff to a device function
    note {|noteChan, note, debug=false|

        var noteonkey = "%_noteon".format(this.key).asSymbol;
        var noteoffkey = "%_noteoff".format(this.key).asSymbol;

        if (note.isNil) {
            note = (0..110);
        };

        MIDIdef.noteOn(noteonkey.debug("noteonkey"), {|vel, note, chan|
            synth.on(note, vel, debug:debug);
        }, noteNum:note, chan:noteChan)
        .fix;

        MIDIdef.noteOff(noteoffkey.debug("noteoffkey"), {|vel, note, chan|
            synth.off(note);
        }, noteNum:note, chan:noteChan)
        .fix;
    }

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
        };
        oldDestinations.keys.difference(destinations.keys).do {|removed|
            // MacOS does not need to connect
            [ \destinationRemoved, oldDestinations[removed] ].postln;
        };

        sources.keys.difference(oldSources.keys).do {|added|
            [ \sourceAdded, sources[added] ].postln;
            MIDIIn.connect(device:sources[added]);
        };
        destinations.keys.difference(oldDestinations.keys).do {|added|
            // MacOS does not need to connect
            [ \destinationAdded, destinations[added] ].postln;
        };

	}

    *cc {|ccNum, ccChan=0, func, spec|
        var cckey = "cc_%_%".format(ccNum, ccChan).asSymbol.debug("mididef");
        if (spec.notNil) {
            spec = spec.asSpec;
        };

        if (func.isNil) {
            MIDIdef(cckey).permanent_(false).free;
        } {
            MIDIdef.cc(cckey, {|val, num, chan|
                if (spec.notNil) {
                    val = spec.map(val/127);
                };
                func.(val, num, chan);
            }, ccNum:ccNum, chan:ccChan)
            .fix;
        }
    }

    *connect {
        MIDIClient.init(verbose:true);
        MIDIIn.connectAll(verbose:true);
    }

    disconnect {
        "%_noteon".format(this.key).debug("disconnect");
        MIDIdef.noteOn("%_noteon".format(this.key).asSymbol).permanent_(false).free;
        "%_noteoff".format(this.key).debug("disconnect");
        MIDIdef.noteOn("%_noteoff".format(this.key).asSymbol).permanent_(false).free;
    }

    prInit {|argSynth|
        this.synth = argSynth;
    }

    *initClass {
        MIDIClient.init(verbose:true);
        sources = IdentityDictionary();
		destinations = IdentityDictionary();
	}
}

