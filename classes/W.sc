
/*
Workspace
*/

W {

    classvar <all;
    classvar <current;
    classvar <ctrls;
    classvar <mixins;
    classvar <parentEvent;

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

    *parentEvent_ {|evt|
        parentEvent = evt.debug("parentEvent");
        Event.addParentType(\note, parentEvent);
        Event.addParentType(\monoNote, parentEvent);
        Event.addParentType(\monoSet, parentEvent);
        Event.addParentType(\vst_midi, parentEvent);

        /*
        Event.addParentType(\note, (root:0, scale:#[ 0, 2, 5, 7, 9 ], stepsPerOctave: 12));
        g = EnvirGui.new((root:0, scale:#[ 0, 2, 5, 7, 9 ], stepsPerOctave: 9), numItems:8);
        g.putSpec(\stepsPerOctave, [1, 128, \lin, 1, 12]);
        g.putSpec(\root, [-12, 12, \lin, 1, 0]);
        */
    }

    *serverGui {
        Server.default.makeGui
    }

    *tempo_ {|tempo|
        TempoClock.default.tempo = tempo.debug("tempo");
    }

    *tempo {
        ^TempoClock.default.tempo
    }

    *clock {
        ^TempoClock.default
    }

    *initClass { 
        all = IdentityDictionary();
        ctrls = IdentityDictionary();
        mixins = IdentityDictionary();
    }
}
