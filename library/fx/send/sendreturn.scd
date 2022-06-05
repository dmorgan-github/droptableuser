(
synth: {|in|
    var numinput = Server.default.options.numInputBusChannels;
    var sig;
    var sendbus = numinput + \sendbus.kr(0, spec:ControlSpec(0, 32, \lin, 1, 0, "sendreturn"));
    var returnbus = \returnbus.kr(0, spec:ControlSpec(0, 32, \lin, 1, 0, "sendreturn"));
    Out.ar(sendbus, in);
    sig = SoundIn.ar([returnbus, returnbus+1]);
    sig = in.blend(sig, \sendreturn_mix.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, "sendreturn")));
    sig
};
)