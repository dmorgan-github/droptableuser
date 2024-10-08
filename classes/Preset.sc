P : Preset {}
/*
Presets
*/
Preset {

    ///////////////////////////////
    // properties
    *addCurrent {|node, num|
        var vals = Preset.getCurrentVals(node);
        var presets = Preset.getPresets(node);
        num.debug("Preset.addCurrent");
        vals['bufposreplyid'] = nil;
        vals['amp'] = nil;
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
        var presets = Preset.getPresets(node);
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
        var presets = Preset.getPresets(node);
        presets.removeAt(num);
    }

    *morph2 {|node, input|

        var getCurrentVals = {|node|
            var result;
            var specs = node.getSpec.keys;
            result = node.envir.select({|v, k| specs.includes(k) });
            result;
        };
        
        var doMorph = {|node, current, target, blend|
            var specs = node.getSpec;
            var result = current.blend(target, blend);
            var pairs = List();
            result.getPairs.keysValuesDo({|k, v|
                var val;
                var spec = specs[k];
                if (spec.isNil) {
                    spec = [0, 1, \lin, 0, 0].asSpec;
                };
                val = v.round(spec.step);
                pairs.add(k).add(val)
            });
            node.set(*pairs.as(Array));
        };
        
        var morph = {|node, left, right, blend|
            var current = Preset.getPreset(node, left);
            var target = Preset.getPreset(node, right);
            doMorph.(node, current, target, blend)
        };

        var numnodes = Preset.getPresets(node).size;
        var current = input.linlin(0, 127, 0, numnodes-1);
        var blend = current.frac;
        var left = current.floor;
        var right = (left+1).clip(0, numnodes-1);
        morph.(node, left, right, blend);
    }

    *morph {|node, num, beats=20, wait=0.01|
        var key = node.key;
        var presets = Preset.getPresets(node);
        Tdef(key).stop.play;
        Tdef(key, {|ev|
            var presets = ev[\presets];
            var curr = Preset.getCurrentVals(node);
            var target = presets[ev[\preset]];
            var numsteps;
            ev[\dt] ? ev[\dt] ? 0.01;
            ev[\beats] = ev[\beats] ? 1;
            numsteps = ev[\beats]/ev[\dt];
            numsteps.do({|i|
                var blend = 1+i/numsteps;
                var result = curr.blend(target, blend);
                var pairs = List();
                result.getPairs.keysValuesDo({|k,v|
                    var val;
                    var spec = node.getSpec[k];
                    if (spec.isNil) {
                        spec = [0, 1, \lin, 0, 0].asSpec;
                    };
                    val = v.round(spec.step);
                    pairs.add(k).add(val)
                });
                node.set(*pairs.as(Array));
                ev[\dt].wait;
            });
        })
        .set(\presets, presets, \preset, num, \dt, wait, \beats, beats)
        //.play
    }

    *apply{|node, to|
        var preset = Preset.getPreset(node, to);
        if (preset.notNil) {
            node.set(*preset.getPairs);
        } { 
            "no preset: %".format(to).warn
        };
        node.changed(\preset, [to, preset]);
    }

    *blend{|node, from, to, blend=0|
        var frompreset = Preset.getPreset(node, from);
        var topreset = Preset.getPreset(node, to);
        if (frompreset.notNil and: {topreset.notNil}) {
            var result = frompreset.blend(topreset, blend);
            node.set(*result.getPairs);
        }
    }

}
