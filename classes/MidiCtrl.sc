MidiCtrl {

    classvar <skipjack, <>frequency = 0.5;
    classvar <sources, <destinations;
    var <node;

    *new {|node|
        ^super.new.prInit(node);
    }

    note {|noteChan, note, debug=false|

        var key = this.node.key;
        var noteonkey = "%_noteon".format(key).asSymbol;
        var noteoffkey = "%_noteoff".format(key).asSymbol;

        if (note.isNil) {
            note = (0..110);
        };

        MIDIdef.noteOn(noteonkey.debug("noteonkey"), {|vel, note, chan|
            this.node.on(note, vel, debug:debug);
        }, noteNum:note, chan:noteChan)
        .fix;

        MIDIdef.noteOff(noteoffkey.debug("noteoffkey"), {|vel, note, chan|
            this.node.off(note);
        }, noteNum:note, chan:noteChan)
        .fix;
    }

    // TODO: ccChan bookkeeping
    cc {|props, ccNums, ccChan=0|

        var key = this.node.key;
        var cckey = "%_cc_%".format(key, ccChan).asSymbol.debug("mididef");

        if (props.isNil) {
            cckey.debug("disconnect");
            MIDIdef.cc(cckey).permanent_(false).free;
        }{
            var order = Order.newFromIndices(props.asArray, ccNums.asArray);
            MIDIdef.cc(cckey, {|val, num, chan|
                var mapped, ctrl, spec, filter;
                ctrl = order[num];
                spec = node.getSpec(ctrl);
                if (spec.isNil) {
                    spec = [0, 1].asSpec;
                };
                mapped = spec.map(val/127);
                node.set(ctrl, mapped);
            }, ccNum:ccNums, chan:ccChan)
            .fix;

            // initialize midi cc value
            // not sure how to find the correct midiout
            // so trying all of them
            MIDIClient.destinations.do({|dest, i|
                order.indices.do({|num|
                    var ctrl = order[num];
                    var spec = node.getSpec(ctrl);
                    var min, max, current, ccval;
                    if (spec.isNil) {
                        spec = [0, 1].asSpec;
                    };
                    min = spec.minval;
                    max = spec.maxval;
                    current = node.get(ctrl);
                    if (current.notNil) {
                        // don't know how to unmap to a range that is not 0-1
                        if (spec.warp.isKindOf(ExponentialWarp)) {
                            ccval = current.explin(min, max, 0, 127);
                        }{
                            ccval = current.linlin(min, max, 0, 127);
                        };
                        //[node.key, \curent, current, \cc, ccval].debug(ctrl);
                        try {
                            MIDIOut(i).control(ccChan, num, ccval);
                        } {|err|
                            "midi out: %".format(err).warn;
                        }
                    }
                });
            })
        }
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

    disconnect {
        var cckey;
        var key = this.node.key;
        "%_noteon".format(key).debug("disconnect");
        MIDIdef.noteOn("%_noteon".format(key).asSymbol).permanent_(false).free;
        "%_noteoff".format(key).debug("disconnect");
        MIDIdef.noteOn("%_noteoff".format(key).asSymbol).permanent_(false).free;
        cckey = "%_cc_%".format(key, 0).asSymbol.debug("mididef");
        MIDIdef.cc(cckey).permanent_(false).free;
    }

    *connectAll {
        MIDIClient.init(verbose:true);
        MIDIIn.connectAll(verbose:true);
    }

    prInit {|argNode|
        node = argNode;
    }

    *initClass {
        MIDIClient.init(verbose:true);
        sources = IdentityDictionary();
        destinations = IdentityDictionary();
    }
}

