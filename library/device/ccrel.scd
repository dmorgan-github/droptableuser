(
func: {|node, props, ccNums, ccChan=0|

    var incr = (~incr ?? 0.0005).debug("ccrel incr");

    var key = node.key;
    var cckey = "%_ccrel_%".format(key, ccChan).asSymbol.debug("ccrel");

    if (props.isNil) {
        cckey.debug("disconnect");
        MIDIdef.cc(cckey).permanent_(false).free;
    }{
        var order = Order.newFromIndices(props.asArray, ccNums.asArray);
        var vals = Order.newFromIndices(
            props.asArray.collect({|prop|
                var spec = node.getSpec(prop);
                spec.unmap(node.get(prop))
            }),
            ccNums.asArray
        );

        MIDIdef.cc(cckey, {|val, num, chan|
            var mapped, ctrl, spec, current;
            ctrl = order[num];
            current = vals[num];
            spec = node.getSpec(ctrl);
            if (spec.isNil) {
                spec = [0, 1].asSpec;
            };

            val = val - 64;
            val = (current + (val * incr)).clip(0, 1);
            mapped = spec.map(val);
            node.set(ctrl, mapped);
            vals[num] = val;

            val = val.linlin(0, 1, 0, 127);
            MIDIOut(1).control(0, num, val)

        }, ccNum:ccNums, chan:ccChan)
        .fix;

        // initialize midi cc value
        // not sure how to find the correct midiout
        // so trying all of them
        MIDIClient.destinations.do({|dest, i|
            order.indices.do({|num|
                var ctrl = order[num];
                var spec = node.getSpec(ctrl);
                var min, max, current, ccval;
                if (spec.isNil) {
                    spec = [0, 1].asSpec;
                };
                min = spec.minval;
                max = spec.maxval;
                current = node.get(ctrl);
                if (current.notNil) {
                    ccval = current.linlin(min, max, 0, 127);
                    //[\curent, current, \cc, ccval].debug(ctrl);
                    try {
                        MIDIOut(i).control(ccChan, num, ccval);
                    } {|err|
                        "midi out: %".format(err).warn;
                    }
                }
            });
        })
    }
},
doc: "
MIDIClient.init
MIDIIn.connectAll
Module('device/ccrel').put('incr', 0.0005).(~harm, 16.collect({|i| \"harm%\".format(i+1).asSymbol }), (16..31))
"
)