/*
Presets
*/
P {

    ///////////////////////////////
    // properties
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

        var vals = if (node.respondsTo(\controlKeys)) {
            node.controlKeys;
        }{
            node.envir.keys;
        };

        vals = vals
        .select({|key| 
            node.get(key).isNumber or: {node.get(key).isArray}
        })
        .collect({|key| [key, node.get(key)] });

        ^vals.asArray.flatten.asDict
    }

    *remove {|node, num|
        var presets = P.getPresets(node);
        presets.removeAt(num);
    }

    *morph {|node, num, beats=20, wait=0.01|
        var key = node.key;
        var presets = P.getPresets(node);
        Tdef(key).stop.play;
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
        //.play
    }

    *blend{|node, from, to, blend=0|
        var frompreset = P.getPreset(node, from);
        var topreset = P.getPreset(node, to);
        if (frompreset.notNil and: {topreset.notNil}) {
            var result = frompreset.blend(topreset, blend);
            node.set(*result.getPairs);
        }
    }

    ///////////////////////////////
    // sources
    *addCurrentSource {|node, num|
        var key = node.key;
        var vals = P.getCurrentSource(node);
        var sources = Halo.at(\source, key);
        if (sources.isNil) {
            sources = Order.new;
            Halo.put(\source, key, sources);
        };
        sources.put(num, vals);
    }

    *getSources {|node|
        var key = node.key;
        var sources = Halo.at(\source, key);
        if (sources.isNil) {
            sources = Order.new;
            Halo.put(\source, key, sources);
        }
        ^sources
    }

    *getSource {|node, num|
        var key = node.key;
        var sources = P.getSources(node);
        ^sources[num];
    }

    *getCurrentSource {|node|
        ^node.source
    }

    *removeSource {|node, num|
        var sources = P.getSources(node);
        sources.removeAt(num);
    }

    *morphSource {|node, num, fadeTime=20|
        var tosource = P.getSource(node, num);
        node.fadeTime = fadeTime;
        node.source = tosource;
    }

}
