V {

    *ls {
        var result = List.new;
        // this requires search to have been called 
        VSTPlugin.readPlugins.keysValuesDo({arg k, v; result.add(k) });
        result.sort.do({|val| val.postln;});
        ^result;
    }

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
    
}
