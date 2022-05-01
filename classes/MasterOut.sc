MasterOut {

    classvar <eqplugin, <analyzerplugin, <synth;

    *free {
        eqplugin.close;
        analyzerplugin.close;
        synth.free;
    }

    *eq {
        eqplugin.editor
    }

    *analyzer {
        analyzerplugin.editor
    }

    *start {
        Routine({
            "start synth".inform;
            synth = Synth(\masterout, target: RootNode(Server.default), addAction: \addToTail);
            1.wait;
            eqplugin = VSTPluginController(synth, id:'eq');
            analyzerplugin = VSTPluginController(synth, id:'analyzer');
            "load eq".inform;
            eqplugin.open('MEqualizer.vst3', editor:true);
            "load analyzer".inform;
            analyzerplugin.open('MLoudnessAnalyzer.vst3', editor:true);
        }).play
    }

    *prepare {

        // can't create this at start up since the plugin subsystem
        // hasn't been loaded yet
        "adding masterout synthdef".debug("MasterOut");
        SynthDef(\masterout, {
            var in = In.ar(0, 2);
            in = VSTPlugin.ar(in, 2, id: 'eq', info:'MEqualizer.vst3');
            in = VSTPlugin.ar(in, 2, id: 'analyzer', info:'MLoudnessAnalyzer.vst3');
            ReplaceOut.ar(0, in * \master.kr(1)) ;
        }).add;
    }

    *initClass {
    }
}