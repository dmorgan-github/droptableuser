
/*
Presets
*/
P {

    *hh {
        var obj = S(\hh).mono(\plaits_mono);
        obj.set(
            \engine, 15,
            \harm, 0.5,
            \timbre, 0.91,
            \morph, 0.2,
        );
        ^obj;
    }

    *sd {
        var obj = S(\sd).mono(\plaits_mono);
        obj.set(
            \engine, 14,
            \harm, 0.94,
            \timbre, 0.17,
            \morph, 0,
        );
        ^obj;
    }

    *bd {
        var obj = S(\bd).mono(\plaits_mono);
        obj.set(
            \engine, 13,
            \octave, 3,
            \harm, 0.32,
            \timbre, 0.8,
            \morph, 0.17,
        );
        ^obj;
    }

    *addPreset {|node, num, preset|
        var key = node.key;
        var presets = Halo.at(key);
        if (presets.isNil) {
            presets = Order.new;
            Halo.put(key, presets);
        };
        presets.put(num, preset);
    }

    *getPresets {|node|
        var key = node.key;
        var presets = Halo.at(key);
        if (presets.isNil) {
            presets = Order.new;
            Halo.put(key, presets);
        }
        ^presets
    }

    *getPreset {|node, num|
        var key = node.key;
        var presets = P.getPresets(node);
        ^presets[num];
    }

    *morph {|node, from, to, numsteps=20, wait=0.1|
        var key = node.key;
        Routine({
            var presets = P.getPresets(node);
            var numsteps = 20;
            var fromCopy = presets[from].copy;
            var toPreset = presets[to];
            numsteps.do({|i|
                var blend = 1 + i / numsteps;
                fromCopy = fromCopy.blend(toPreset, blend);
                node.set(*fromCopy.getPairs);
                wait.wait;
            });
            \morph_done.debug(key);
        }).play;
    }
}