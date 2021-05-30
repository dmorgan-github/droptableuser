/*
Workspace
*/
W : EnvironmentRedirect {

    classvar <current;

    classvar <>matrixenabled;

    var matrixListener;

    var <matrix;

    var <knobMap;

    *push {
		currentEnvironment.clear.pop;  // avoid nesting
		current = super.new.init.push;
        ^current;
	}

	at {|key|

		var obj = super.at(key);
		if(obj.isNil) {

            case
            {key.asString.beginsWith("s")} {
                obj = S(key);
            }
            {key.asString.beginsWith("d")} {
                obj = D(key);
            }
            {key.asString.beginsWith("o")} {
                obj = O(key);
            };

            if (obj.notNil) {
                this.put(key, obj);
            }
		};

		^obj
	}

    put {|key, obj|
        super.put(key, obj);
        if (matrixenabled) {
            if (obj.isKindOf(S)) {
                matrix.addSrc(obj.node);
            }{
                if (obj.isKindOf(D)) {
                    matrix.addSrc(obj);
                }
            }
        }
    }

    init {

        matrixListener = {|obj, event, val|
            if (event == \add) {
                var key = val.key;
                if (envir.keys.includes(key).not) {
                    envir.put(key, val);
                }
            };
        };

        matrix = M(\m);
        matrix.addDependant(matrixListener);
        knobMap = Order.new;
    }

    mixer {
        ^matrix;
    }

    twister {
        ^U(\twister)
    }

    *transport {|clock|
        U(\transport, clock);
    }

    *setParentEvent {|evt|
        Event.addParentType(\note, evt);
        Event.addParentType(\monoNote, evt);
        Event.addParentType(\monoSet, evt);

        /*
        Event.addParentType(\note, (root:0, scale:#[ 0, 2, 5, 7, 9 ], stepsPerOctave: 12));
        g = EnvirGui.new((root:0, scale:#[ 0, 2, 5, 7, 9 ], stepsPerOctave: 9), numItems:8);
        g.putSpec(\stepsPerOctave, [1, 128, \lin, 1, 12]);
        g.putSpec(\root, [-12, 12, \lin, 1, 0]);
        */
    }

    *getParentEvent {
        var evt = Event.parentTypes[\note] ?? { () };
        ^evt;
    }

    /*
    *sendToTwister {
        var new = currentEnvironment
        .select({|v, k| v.isKindOf(S) or: v.isKindOf(O) })
        .reject({|v, k| synths.collect({|assoc| assoc.key}).includes(k) })
        .keysValuesDo({|k, v|
            var pos = synths.pos;
            synths.put(pos, k -> v);
            Twister.knobs(pos)
            .ccFunc({|vel|
                if (v.isKindOf(S)) {
                    v.node.vol = vel/127;
                } {
                    v.vol = vel/127;
                }
                //[pos, vel].postln;
            }, [0, 1, \lin, 0, 0])
            .note({ v.play; },{ v.stop; })
            .label_(k);
            //v.set(\vel, Twister.knobs(pos).asMap)
        });
    }
    */

    *recdir {|path|
        var mypath = path ?? {Document.current.dir};
        thisProcess.platform.recordingsDir_(mypath.debug(\recdir));
    }

    *record {
        var filename = "SC_" ++ Date.getDate.stamp ++ ".wav";
        var path = thisProcess.platform.recordingsDir ++ filename;
        Server.default.record(path, bus:D.defaultout, numChannels:2);
        Document.current.string_("/*%*/\n".format(filename), 0, 0);
    }

    *stopRecording {
        Server.default.stopRecording;
    }

    *initClass {
        matrixenabled = true;
    }
}