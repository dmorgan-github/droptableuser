(
synth: {
    var params = ~params;
    var info = ~info;
    var sig = VSTPlugin.ar(Silent.ar(2), 2,
        params: params,
        info: info
    );
    sig;
}
)