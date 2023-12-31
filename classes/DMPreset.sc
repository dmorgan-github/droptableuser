P : DMPreset {}
/*
Presets
*/
DMPreset {

    ///////////////////////////////
    // properties
    *addCurrent {|node, num|
        var vals = DMPreset.getCurrentVals(node);
        var presets = DMPreset.getPresets(node);
        presets.put(num, vals);
    }

    *getPresets {|node|
        var key = node.key;
        var presets = Library.at(node, \presets);
        if (presets.isNil) {
            presets = Order.new;
            Library.put(node, \presets, presets);
            node.addDependant({|obj, what|
                if (what == \clear) {
                    "clear presets".debug(node.key);
                    Library.put(this, \presets, nil)
                }
            });
        }
        ^presets
    }

    *getPreset {|node, num|
        var key = node.key;
        var presets = DMPreset.getPresets(node);
        ^presets[num];
    }

    *getCurrentVals {|node|

        var vals = if (node.respondsTo(\controlKeys)) {
            node.controlKeys;
        }{
            node.envir.keys;
        };

        vals = vals
        .select({|key|
            var val = node.get(key);
            val.isNumber or: { val.isArray.and({val.size > 0}).and({val[0].isNumber}) }
        })
        .reject({|key|
            (key == \amp) or: {key == \bend} or: {key == \vel}
        })
        .collect({|key| [key, node.get(key)] });

        ^vals.asArray.flatten.asDict
    }

    *remove {|node, num|
        var presets = DMPreset.getPresets(node);
        presets.removeAt(num);
    }

    *morph {|node, num, beats=20, wait=0.01|
        var key = node.key;
        var presets = DMPreset.getPresets(node);
        Tdef(key).stop.play;
        Tdef(key, {|ev|
            var presets = ev[\presets];
            var curr = DMPreset.getCurrentVals(node);
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
        //.play
    }

    *apply{|node, to|
        var preset = DMPreset.getPreset(node, to);
        if (preset.notNil) {
            node.set(*preset.getPairs);
        } { 
            "no preset: %".format(to).warn
        };
        node.changed(\preset, [to, preset]);
    }

    *blend{|node, from, to, blend=0|
        var frompreset = DMPreset.getPreset(node, from);
        var topreset = DMPreset.getPreset(node, to);
        if (frompreset.notNil and: {topreset.notNil}) {
            var result = frompreset.blend(topreset, blend);
            node.set(*result.getPairs);
        }
    }

}
