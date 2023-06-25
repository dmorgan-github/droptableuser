(
func: {|node, props, ccNums, ccChan=0|

    var key = node.key;
    var cckey = "%_cc_%".format(key, ccChan).asSymbol.debug("mididef");

    if (props.isNil) {
        cckey.debug("disconnect");
        MIDIdef.cc(cckey).permanent_(false).free;
    }{
        var order = Order.newFromIndices(props.asArray, ccNums.asArray);
        MIDIdef.cc(cckey, {|val, num, chan|
            var mapped, ctrl, spec, filter;
            ctrl = order[num];
            spec = node.getSpec(ctrl);
            if (spec.isNil) {
                spec = [0, 1].asSpec;
            };
            mapped = spec.map(val/127);
            node.set(ctrl, mapped);
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
Module('device/cc').(~harm, 16.collect({|i| \"harm%\".format(i+1).asSymbol }), (0..15))
"
)