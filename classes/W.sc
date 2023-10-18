
/*
Workspace
*/


W {

    classvar <all;
    classvar <current;
    classvar <ctrls;
    classvar <mixins;

    *init {

        var name = PathName(Document.current.path).folderName.asSymbol;

        if (current.notNil) {
            // if there is a current environment
            // save it's current state
            all[current] = currentEnvironment;
        };

        // if name exists make it current;
        if (all[name].notNil) {
            currentEnvironment = all[name];
        } {
            // if the name doesn't exist, create a new entry
            // and make the supplied environment current;
            currentEnvironment = Environment();
            all[name] = currentEnvironment;
        };
        current = name.debug("current context");
    }

    *initClass { 
        all = IdentityDictionary();
        ctrls = IdentityDictionary();
        mixins = IdentityDictionary();
    }
}


W2 : EnvironmentRedirect {

    classvar <current, <>clock;

    classvar <>matrixenabled;

    classvar <>count=0;

    var <matrix;

    *push {
		currentEnvironment.clear.pop;  // avoid nesting
		current = super.new.init.push;
        ^current;
	}

	at {|key|

        var obj;
        obj = super.at(key);

        /*
        \here.postln;
		if(obj.isNil) {

            obj = InstrProxy();
            \here2.postln;
            //obj.key = key;
            obj.clock = W.clock;
            //obj.node.out = D.defaultout + (tracks * 2);
            //daw.asClass.trackname(tracks + 1, key);
            //tracks = tracks + 1;
            //if (obj.notNil) {
            //    this.put(key, obj);
            //}
		};
        */

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

        /*
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
        */
    }

    /*
    *ndefmixer {
        var m = NdefMixer(Server.default, 8);
        m.switchSize(0);
        ProxyMeter.addMixer(m);
    }
    */

    /*
    mixer {
        ^matrix;
    }
    */

    /*
    *view {
        ^UiModule(\wview)
    }
    */

    /*
    *kb {
        ^Ui(\kb)
    }
    */

    /*
    *transport {|clock|
        Ui(\transport, clock);
    }
    */

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

    *initClass {
        //matrixenabled = true;
        clock = TempoClock.default;
        //daw = \Bitwig;
    }
}
