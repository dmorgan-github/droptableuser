(
func: {|node|

    var server = Server.default;
    //var numRMSSamps, numRMSSampsRecip;
    var updateFreq = 10, dBLow = -80;
    var levelkey = node.key;
    var bus, numchannels;
    var meterWidth = 15;
    var meters, view, synth;
    var metercolor = if (node.isMonitoring) {node.color}{Color.grey};

    var monitorwatcher = {|obj, what|
        if (what == \play) {
            meters.do({|m|
                m.meterColor = node.color;
            })
        }{
            if (what == \stop) {
                meters.do({|m|
                    m.meterColor = Color.grey;
                })
            }
        }
    };

    node = if (node.respondsTo(\node)) {node.node}{node};
    bus = node.bus.index;
    numchannels = node.bus.numChannels;

    //numRMSSamps = server.sampleRate / updateFreq;
	//numRMSSampsRecip = 1 / numRMSSamps;

    meters = Array.fill( numchannels, { arg i;
        var li = LevelIndicator().warning_(0.9).critical_(1.0)
        .drawsPeak_(true)
        .style_(\led)
        .numSteps_(30)
        .meterColor_(metercolor);
        //.numTicks_( if (i == 0) {0}{9})
        //.numMajorTicks_(if (i == 0) {0}{3});
        //if (i == 0) {
        li.minWidth = 175;
        li.fixedHeight = 8
        //}{
        //   li.maxWidth = 20
        //}
    });

    synth = SynthDef(levelkey ++ "OutputLevels", {
        var in = InFeedback.ar(bus, numchannels).asArray;
        SendPeakRMS.kr(in, updateFreq, 3, "/" ++ levelkey ++ "OutLevels")
    }).play(node.group.nodeID, nil, \addToTail);
    // should this be the node group or monitor group?
    //node.monitor.group.nodeID

    OSCdef(levelkey, {|msg|
        {
            try {

                var channelCount = min(msg.size - 3 / 2, numchannels);
                channelCount.do {|channel|
                    var baseIndex = 3 + (2*channel);
                    var peakLevel = msg.at(baseIndex);
                    var rmsValue = msg.at(baseIndex + 1);
                    var meter = meters.at(channel);
                    if (meter.notNil) {
                        if (meter.isClosed.not) {
                            meter.peakLevel = peakLevel.ampdb.linlin(dBLow, 0, 0, 1, \min);
                            meter.value = rmsValue.ampdb.linlin(dBLow, 0, 0, 1);
                        }
                    }
                }
            } { |error|
                if(error.isKindOf(PrimitiveFailedError).not) { error.throw }
            };
        }.defer;
    }, ("/" ++ levelkey ++ "OutLevels").asSymbol, server.addr);

    node.addDependant(monitorwatcher);

    view = View().layout_(

        VLayout(*meters).margins_(1).spacing_(1)

        /*
        VLayout(
            HLayout(
                Slider().orientation_(\vertical)
                .thumbSize_(0.5)
                .knobColor_(Color.cyan)
                .action_({|ctrl|
                    var val = ctrl.value.linlin(0, 1, 0, 2);
                    node.set(\vol, val);//.debug(node.key);
                })
                .maxWidth_(20)
                .value_(node.vol.linlin(0, 2, 0, 1))
                .mouseDownAction_({|ctrl, x, y, mod, button, count|
                    if (count == 2) {
                        node.set(\vol, 1);//.debug(node.key);
                        ctrl.value = 1.linlin(0, 2, 0, 1);
                        true
                    }
                }),
                HLayout(*meters).margins_(1).spacing_(1),
                nil
            ),


            Slider()
            .orientation_(\horizontal)
            .thumbSize_(0.5)
            .knobColor_(Color.cyan)
            .value_(node.get(\spread) ?? 1)
            .action_({|ctrl|
                node.set(\spread, ctrl.value)
            })
            .maxHeight_(15)
            .maxWidth_(60),

            Slider()
            .orientation_(\horizontal)
            .thumbSize_(0.5)
            .knobColor_(Color.cyan)
            .maxHeight_(15)
            .maxWidth_(60)
            .value_((node.get(\center) ?? 0).linlin(-1, 1, 0, 1))
            .action_({|ctrl|
                node.set(\center, ctrl.value.linlin(0, 1, -1, 1))
            }),

        ).spacing_(0).margins_(0)
        */
    );
    view
    .minWidth_(75)
    .onClose_({
        //"free".debug("meter");
        node.removeDependant(monitorwatcher);
        synth.free;
        OSCdef(levelkey).free;
    });
}
)
