(
func: {|node|

    var server = Server.default;
    //var numRMSSamps, numRMSSampsRecip;
    var updateFreq = 10, dBLow = -80;
    var levelkey = node.key;
    var bus, numchannels;
    var meterWidth = 15;
    var meters, view, synth;
    var metercolor = if (node.isMonitoring) {Color.green}{Color.yellow};

    var monitorwatcher = {|obj, what|
        if (what == \play) {
            meters.do({|m|
                m.meterColor = Color.green;
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
        LevelIndicator(bounds:Rect(0, 0, meterWidth, 180) ).warning_(0.9).critical_(1.0)
        .drawsPeak_(true)
        .meterColor_(metercolor)
        .numTicks_(9)
        .numMajorTicks_(3);
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
        HLayout(
            Slider().orientation_(\vertical)
            .thumbSize_(0.5)
            .knobColor_(Color.cyan)
            .action_({|ctrl|
                var val = ctrl.value.linlin(0, 1, 0, 2);
                node.set(\vol, val);//.debug(node.key);
            })
            .fixedWidth_(20)
            .value_(node.vol.linlin(0, 2, 0, 1))
            .mouseDownAction_({|ctrl, x, y, mod, button, count|
                if (count == 2) {
                    node.set(\vol, 1);//.debug(node.key);
                    ctrl.value = 1.linlin(0, 2, 0, 1);
                    true
                }
            }),
            HLayout(*meters)//.margins_(7).spacing_(7)
        )
    );
    view
    .fixedWidth_(110)
    .onClose_({
        "free".debug("meter");
        node.removeDependant(monitorwatcher);
        synth.free;
        OSCdef(levelkey).free;
    });
}
)
