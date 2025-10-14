
/*
unipolar: sig + (mod * moddepth)
unipolar with env: ffreq * (1 + (modFactor * eg))
bipolar: sig * (2 ** (mod * moddepth))
*/


ResetLfo : UGen {

    *kr {|freq, modratio=1, modindex=0, reset|
        ^ResetLfo.prAudio('kr', freq, modratio, modindex, reset)
    }

    *ar {|freq, modratio=1, modindex=0, reset|
        ^ResetLfo.prAudio('ar', freq, modratio, modindex, reset)
    }

    *prAudio {|rate, freq, modratio=1, modindex=0, reset=1|
        var phase = Phasor.ar(reset, freq * [1, modratio] * SampleDur.ir);
        var mod = SinOsc.perform(rate, DC.perform(rate, 0), phase[1]) / 2pi * modindex;
        var sig = SinOsc.perform(rate, DC.perform(rate, 0), phase[0] + mod * 2pi);
        ^sig;
    }
}

Lfo {

    var <funcs;

    *new {
        ^super.new.init
    }

    sine  {|val=0.5, depth=0, rate=1|
        var settings = [val, depth, rate].flop;
        funcs = settings.collect({|val, i|
            var v = val[0];
            var d = val[1];
            var r = val[2];
            {
                var lfo;
                var prefix = ~key ?? 'lfo';
                var valctl = NamedControl("%_val".format(prefix).asSymbol, v, 0.1 );
                var depthctrl = NamedControl( "%_depth".format(prefix).asSymbol, d, 0.1 );
                var ratectrl = NamedControl( "%_rate".format(prefix).asSymbol, r, 0.1 );
                // sig = valctl * ( depthctrl.linlin(0, 1, 1, 2) ** SinOsc.kr(ratectrl));

                lfo = SinOsc.kr(ratectrl) * depthctrl;
                lfo = 2 ** lfo;
                lfo = valctl * lfo;
                lfo
            }
        });
    }

    value {|key|
        ^funcs.collect({|func, i|
            var mykey = "%%".format(key, i).asSymbol;
            func = func.inEnvir( (key: mykey) );
            Ndef(mykey, func)
        })    
    }

    *sine  {|val=0.5, depth=0, rate=1, poll=0|
        ^Lfo().sine(val, depth, rate)
    }

    init {
        ^this
    }

}

/*
LfoDef {

    classvar <order;

    *new {
        ^super.new.init
    }

    *sine  {|key, val=0.5, depth=0, rate=1, poll=0|
        LfoDef().sine(val=0.5, depth=0, rate=1)
    }

    put {|index, val|
        var node = order[index];
        if (node.isNil) {
            node = NodeProxy();
            order.put(index, node);
        };
        node[0] = val;
    }

    at {|index|
        ^order[index]    
    }

    init {
        ^this
    }

    *initClass {
        order = Order()
    }

}
*/