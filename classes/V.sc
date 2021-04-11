V : D {

    var <>fx, <>synth, <vst;

    var <onload;

    load {|name, func|
        var index = 100;
        vst = name;
        onload = func;
        V.prFunc(index, this, vst, {|fx, synth| this.fx = fx; this.synth = synth;}, onload);
    }

    *prFunc {|index, node, vst, cb, onload|

        var fx, synth;

        var func = {

            Routine({
                node.wakeUp;
                node.send;
                node[index] = \vst.debug(\synthdef);
                synth = Synth.basicNew(\vst, Server.default, node.objects[index].nodeID);
                Server.default.latency.wait;
                synth.set(\in, node.bus.index);
                fx = VSTPluginController(synth);
                Server.default.latency.wait;
                fx.open(vst.asString, verbose:true, editor:true);
                //Server.default.latency.wait;
                // don't understand this but it is necessary
                // to get the paramcache populated
                fx.addDependant(node);
                cb.(fx, synth);
                if (onload.isNil.not) {
                    { onload.(fx) }.defer(2);
                };

            }).play;
        };

        func.();
        ServerTree.add(func);
    }

    *ls {
        var result = List.new;
        VSTPlugin.search(verbose:false);
        VSTPlugin.readPlugins.keysValuesDo({arg k, v; result.add(k) });
        result.sort.do({|val| val.postln;});
        ^result;
    }

    *printSynthParams {|vst, ctrl|
        var params = ctrl.info.parameters;
        var cache = ctrl.paramCache;
        var vals = List.new;
        params.do({|p, i|
            vals.add(p['name'].asSymbol -> cache[i][0]);
        });

        vals.sort({|a, b| a.key.asString < b.key.asString }).do({|assoc|
            var k = assoc.key;
            var v = assoc.value;
            var vstkey = vst.asString.select({|val| val.isAlphaNum}).toLower;
            var param = k.asString.select({|val| val.isAlphaNum}).toLower;
            var named = "%_%".format(vstkey, param)[0..30];
            ("'" ++ k ++ "'" ++ ", " ++ "'%".format(named) ++ "'.kr(%)".format(v) ++ ",").postln;
        })
    }

    *printPatternParams {|vst, ctrl|
        var params = ctrl.info.parameters;
        var cache = ctrl.paramCache;
        var vals = List.new;
        params.do({|p, i|
            vals.add(p['name'].asSymbol -> cache[i][0]);
        });

        vals.sort({|a, b| a.key.asString < b.key.asString }).do({|assoc|
            var k = assoc.key;
            var v = assoc.value;
            var vstkey = vst.asString.select({|val| val.isAlphaNum}).toLower;
            var param = k.asString.select({|val| val.isAlphaNum}).toLower;
            var named = "%_%".format(vstkey, param)[0..30];
            ("'" ++ named ++ "', %".format(v) ++ ",").postln;
        })
    }

    set {|key, val|

        if ( fx.isNil.not and: { fx.info.parameters
            .collect({|dict| dict['name'].asSymbol })
            .includes(key) }
        ) {
            fx.set(key, val);
        }{
            super.set(key, val);
        }
    }

    editor {
        ^fx.editor;
    }

    vgui {
        ^fx.gui;
    }

    browse {
        fx.browse;
    }

    /*
    snapshot {
    fx.getProgramData({ arg data; pdata = data;});
    }
    */

    /*
    restore {
    fx.setProgramData(pdata);
    }
    */

    bypass {arg bypass=0;
        synth.set(\bypass, bypass)
    }

    parameters {
        ^fx.info.printParameters
    }

    settings {|cb|
        var vals = ();
        var parms = fx.info.parameters;
        fx.getn(action: {arg v;
            v.do({|val, i|
                var name = parms[i][\name];
                vals[name] = val;
            });
            cb.(vals);
        });
    }

    getSettings {
        var params = fx.info.parameters;
        var cache = fx.paramCache;
        var vals = ();
        params.do({|p, i|
            vals[p['name'].asSymbol] = cache[i][0];
        });
        vals = vals ++ this.getKeysValues.flatten.asDict;
        ^vals;
    }

    clear {
        //skipjack.stop;
        //SkipJack.stop(key);
        synth.free;
        synth.release;
        fx.close;
        fx = nil;
        fx.removeDependant(this);
        super.clear;
    }

    *initClass {
        StartUp.add({
            SynthDef.new(\vst, {arg out;
                var sig = In.ar(out, 2);
                //var wet = ('wet100').asSymbol.kr(1);
                //XOut.ar(in, wet, VSTPlugin.ar(sig, 2));
                ReplaceOut.ar(out, VSTPlugin.ar(sig, 2));
            }).add;

            //VSTPlugin.search;
        });
    }
}