// can't create this at start up since the plugin subsystem
// hasn't been loaded yet
"adding masterout synthdef".debug("MasterOut");
SynthDef(\masterout, {
    var in = In.ar(0, 2);
    in = VSTPlugin.ar(in, 2, id: 'eq', info:'MEqualizer.vst3');
    in = VSTPlugin.ar(in, 2, id: 'analyzer', info:'MAnalyzer.vst3');
    in = VSTPlugin.ar(in, 2, id: 'stereo', info:'MStereoScope.vst3');
    in = VSTPlugin.ar(in, 2, id: 'loudness', info:'MLoudnessAnalyzer.vst3');
    ReplaceOut.ar(0, in * \master.kr(1)) ;
}).add;

(
func: {

    var obj = ();

    obj['start'] = {

        Routine({
            var synth, eqplugin, analyzerplugin, stereoplugin, loudnessplugin;
            "start synth".inform;
            synth = Synth(\masterout, target: RootNode(Server.default), addAction: \addToTail);
            1.wait;
            eqplugin = VSTPluginController(synth, id:'eq');
            analyzerplugin = VSTPluginController(synth, id:'analyzer');
            loudnessplugin = VSTPluginController(synth, id:'loudness');
            stereoplugin = VSTPluginController(synth, id:'stereo');

            "load eq".inform;
            eqplugin.open('MEqualizer.vst3', editor:true);
            "load analyzer".inform;
            loudnessplugin.open('MLoudnessAnalyzer.vst3', editor:true);
            "load stereo".inform;
            stereoplugin.open('MStereoScope.vst3', editor:true);
            "load analyzer".inform;
            analyzerplugin.open('MAnalyzer.vst3', editor:true);

            obj['eqplugin'] = eqplugin;
            obj['analyzerplugin'] = analyzerplugin;
            obj['stereoplugin'] = stereoplugin;
            obj['loudnessplugin'] = loudnessplugin;
            obj['synth'] = synth;
        }).play

    };

    obj['end'] = {
        'end'.debug("masterout");
        obj['eqplugin'].close;
        obj['analyzerplugin'].close;
        obj['stereoplugin'].close;
        obj['loudnessplugin'].close;
        obj['synth'].free;
    };

    obj['eq'] = {
        obj['eqplugin'].editor
    };

    obj['analyzer'] = {
        obj['analyzerplugin'].editor
    };

    obj['loudness'] = {
        obj['loudnessplugin'].editor
    };

    obj['stereo'] = {
        obj['stereoplugin'].editor
    };

    obj;
}
)