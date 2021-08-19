/*
Workspace
*/
W : EnvironmentRedirect {

    classvar <current, <>clock;

    classvar <>matrixenabled;

    classvar <>tracks=0;

    classvar <>daw;

    var matrixListener;

    var <matrix;

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
                obj.clock = W.clock;
                obj.node.out = D.defaultout + (tracks * 2);
                daw.asClass.trackname(tracks + 1, key);
                tracks = tracks + 1;
            }
            {key.asString.beginsWith("d")} {
                obj = D(key);
                obj.out = D.defaultout + (tracks * 2);
                daw.asClass.trackname(tracks + 1, key);
                tracks = tracks + 1;
            }
            {key.asString.beginsWith("o")} {
                obj = O(key);
                obj.out = D.defaultout + (tracks * 2);
                daw.asClass.trackname(tracks + 1, key);
                tracks = tracks + 1;
            }
            {key.asString.beginsWith("g")} {
                obj = G(key);
                obj.out = D.defaultout + (tracks * 2);
                daw.asClass.trackname(tracks + 1, key);
                tracks = tracks + 1;
            };

            if (obj.notNil) {
                this.put(key, obj);
            }
		};

		^obj
	}

    includes { |proxy| ^envir.includes(proxy) }

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
    }

    *ndefmixer {
        var m = NdefMixer(Server.default);
        ProxyMeter.addMixer(m);
    }

    mixer {
        ^matrix;
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

    *recdir {|path|
        var mypath = path ?? {Document.current.dir};
        thisProcess.platform.recordingsDir_(mypath.debug(\recdir));
    }

    *currentRecDir {
        W.recdir(PathName(Document.current.path).pathOnly)
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
        clock = TempoClock.default;
        daw = \Bitwig;
    }
}