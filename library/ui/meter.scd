(
func: {|node|

    var server = Server.default;
    //var numRMSSamps, numRMSSampsRecip;
    var updateFreq = 10, dBLow = -80;
    var levelkey = node.key;
    var bus, numchannels;
    var meterWidth = 15;
    var meters, view, synth;

    bus = node.bus.index;
    numchannels = node.bus.numChannels;

    //numRMSSamps = server.sampleRate / updateFreq;
	//numRMSSampsRecip = 1 / numRMSSamps;

    meters = Array.fill( numchannels, { arg i;
        LevelIndicator(bounds:Rect(0, 0, meterWidth, 180) ).warning_(0.9).critical_(1.0)
        .drawsPeak_(true)
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

    view = View().layout_(HLayout(*meters));
    view
    .fixedWidth_(75)
    .onClose_({
        "free".debug("meter");
        synth.free;
        OSCdef(levelkey).free;
    });
}
)
