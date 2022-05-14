V {

    classvar <surge="vst:Surge XT.vst3";
    classvar <vital="vst:Vital.vst3";
    classvar <reaktor="vst:Reaktor 6";
    classvar <dexed="vst:Dexed.vst3";
    classvar <pendulate="vst:Pendulate.vst3";

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

    /*
    (
Routine({

    ~vst.do({|key|

        var str, file;
        var path = "~/projects/droptableuser/library/vst/%.scd".format(key.asString).standardizePath.postln;
        var vst = V('a').load(key.asSymbol);
        2.wait;
        str = V.printSynthParams(key.asSymbol, vst.fx);
        file = File.new(path, "w");
        file.write(str);
        file.close;

    });

}).play;
)
    */
    *getSynthParams {|vst, ctrl, cb|

        var params = ctrl.info.parameters;
        var vals = List.new;

        var mycb = {|vals|

            var string = "(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [\n";

        vals.sort({|a, b| a.key.asString < b.key.asString }).do({|assoc|
            var k = assoc.key;
            var v = assoc.value;
            var vstkey = vst.asString.select({|val| val.isAlphaNum}).toLower;
            var param = k.asString.select({|val| val.isAlphaNum}).toLower;
            var named = "%_%".format(vstkey, param)[0..30];
            string = string ++ ("\t\t\t'" ++ k ++ "'" ++ ", " ++ "'%".format(named) ++ "'.kr(%)".format(v) ++ ",");//.postln;
            string = string ++ "\n";
        });
        string = string ++ "\t\t],
\t\tinfo:'%'
    )
}
)".format(ctrl.info.name);

            cb.(string);
        };

        ctrl.getn(action: {arg v;
            v.do({|val, i|
                var name = params[i][\name];
                vals.add( name ->  val);
            });
            mycb.(vals);
        });
    }

    *printPatternParams {|vst, ctrl|
        var params = ctrl.info.parameters;
        var cache = ctrl.parameterCache;
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

    *getPatternParams {|vst, ctrl, cb|
        var returnVal = List.new;
        var mycb = {|vals|
            vals.sort({|a, b| a.key.asString < b.key.asString }).do({|assoc|
                var k = assoc.key;
                var v = assoc.value;
                var vstkey = vst.asString.select({|val| val.isAlphaNum}).toLower;
                var param = k.asString.select({|val| val.isAlphaNum}).toLower;
                var named = "%_%".format(vstkey, param)[0..30];
                //("'" ++ named ++ "', %".format(v) ++ ",").postln;
                returnVal.add( named.asSymbol -> v);
            });
            cb.(returnVal);
        };
        var vals = List.new;
        var parms = ctrl.info.parameters;

        ctrl.getn(action: {arg v;
            v.do({|val, i|
                var name = parms[i][\name];
                vals.add( name ->  val);
            });
            mycb.(vals);
        });
    }

    *printParamVals {|ctrl|
        var cb = {|vals| vals.asCompileString.postln;};
        var vals = ();
        var parms = ctrl.info.parameters;

        ctrl.getn(action: {arg v;
            v.do({|val, i|
                var name = parms[i][\name];
                vals[name] = val;
            });
            cb.(vals);
        });
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