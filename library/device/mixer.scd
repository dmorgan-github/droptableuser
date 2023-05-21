(
func: {

    var obj = ();
    var ipad = Halo.at(\ipad);

    if (ipad.isNil) {
        ipad = NetAddr.new("192.168.86.176", 57125);
        Halo.put(\ipad, ipad);
    };

    obj['ipad'] = ipad;

    obj['mixer'] = {|self, nodes|

        nodes.asArray.do({|node, i|
            var key = "/mix%".format(i+1).asSymbol.debug("mixer");
            var current = node.get('vol');
            OSCdef(key, {|msg|
                var val = msg[1];
                node.set('vol', val)
            }, key);
            ipad.sendMsg(key.asString, current);
        });

        nodes.asArray.do({|node, i|
            var key = "spread%".format(i+1).asSymbol;
            var current = node.get('spread');
            OSCdef(key, {|msg|
                var val = msg[1];
                node.set('spread', val);
            }, key);
            ipad.sendMsg(key.asString, current);
        });

        nodes.asArray.do({|node, i|
            var key = "pan%".format(i+1).asSymbol;
            var current = node.get('center');
            OSCdef(key, {|msg|
                var val = msg[1];
                val = val.linlin(0, 1, -1, 1);
                node.set('center', val);
            }, key);
            ipad.sendMsg(key.asString, current.linlin(-1, 1, 0, 1));
        });

        OSCdef('/mute', {|msg|
            var val = msg[1];

            if (val > 0) {
                Server.default.mute
            }{
                Server.default.unmute
            };
        }, '/mute');

        OSCdef('/rec', {|msg|

            var val = msg[1];
            if (val > 0) {
                Server.default.record
            }{
                Server.default.stopRecording
            }

        }, '/rec');
    };

    obj['grid'] = {|self, node, props, nums|

        var order = Order.newFromIndices(props.asArray, nums.asArray);
        nums.do({|num|
            var prop = order[num].debug("prop");
            var radial = "/radial%".format(num).asSymbol.debug("grid");
            var label = "/label%".format(num);

            if (prop.isNil) {
                OSCdef(radial).permanent_(false).free;
                ipad.sendMsg(radial.asString, 0);
                ipad.sendMsg(label.asString, "");
            }{
                var current = node.get(prop).debug("current");
                var spec = node.getSpec(prop).debug("spec");
                OSCdef(radial, {|msg|
                    var val = msg[1];
                    var mapped = spec.map(val);
                    node.set(prop, mapped);
                }, radial);
                ipad.sendMsg(radial.asString, spec.unmap(current));
                ipad.sendMsg(label.asString, prop.asString);
            }
        })
    };

    obj;
},
doc: "
~mixer = Module('device/mixer').()
~mixer.grid(~piano.node, [\fbdelay_delR, \miverb_mix2, \miverb_time2, \miverb_freeze2], [1, 2, 3, 4])
// to remove
// ~mixer.grid(~piano.node, nil, [1, 2, 3, 4])
"
)
