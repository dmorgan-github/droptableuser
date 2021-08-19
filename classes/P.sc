/*
Presets
*/
P {

    *addCurrent {|node, num|
        var key = node.key;
        var vals = P.getCurrentVals(node);
        var presets = Halo.at(\presets, key);
        if (presets.isNil) {
            presets = Order.new;
            Halo.put(\presets, key, presets);
        };
        presets.put(num, vals);
    }

    *getPresets {|node|
        var key = node.key;
        var presets = Halo.at(\presets, key);
        if (presets.isNil) {
            presets = Order.new;
            Halo.put(\presets, key, presets);
        }
        ^presets
    }

    *getPreset {|node, num|
        var key = node.key;
        var presets = P.getPresets(node);
        ^presets[num];
    }

    *getCurrentVals {|node|
        var vals = node.envir.keys
        .select({|key| node.get(key).isNumber }).
        collect({|key| [key, node.get(key)] });
        ^vals.asArray.flatten.asDict
    }

    *morph {|node, num, beats=20, wait=0.01|
        var key = node.key;
        var presets = P.getPresets(node);
        Tdef(key, {|ev|
            var presets = ev[\presets];
            var curr = P.getCurrentVals(node);
            var target = presets[ev[\preset]];
            var numsteps;
            ev[\dt] ? ev[\dt] ? 0.01;
            ev[\beats] = ev[\beats] ? 1;
            numsteps = ev[\beats]/ev[\dt];
            numsteps.do({|i|
                var blend = 1+i/numsteps;
                var result = curr.blend(target, blend);
                node.set(*result.getPairs);
                ev[\dt].wait;
            });
        })
        .set(\presets, presets, \preset, num, \dt, wait, \beats, beats)
        .play
    }
}