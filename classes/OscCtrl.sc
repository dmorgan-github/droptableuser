/*
(
OscCtrl.paths('/rotary8/r', (1..12), {arg val, num;
var note = 48 + (num-1);
if (val == 1) {
S(\synth1).on(note, 1);
}{
S(\synth1).off(note);
}
});
)
OscCtrl.paths('/rotary8/r', (1..12), nil);
*/

// NetAddr.langPort
OscCtrl {

    /*
    Note: use symbol notation for path
    */
    *path {arg path, func;
        var key = path.asSymbol;
        if (func.isNil) {
            "free %".format(key).postln;
            OSCdef(key).free;
        }{
            "register %".format(key).postln;
            OSCdef.newMatching(key, {arg msg, time, addr, recvPort;
                var val = msg[1..];
                func.(val);
                nil;
            }, key).permanent_(true);
        };
    }

    /*
    Note: use symbol notation for prefix
    */
    *paths {arg prefix, nums, func;
        if (func.isNil) {
            nums.do({arg i;
                var path =  "%%".format(prefix, i).asSymbol;
                "free %".format(path).debug(\many);
                OSCdef(path).free;
            });
        }{
            nums.do({arg i;
                var path =  "%%".format(prefix, i).asSymbol;
                "register %".format(path).debug(\many);
                OSCdef.newMatching(path, {arg msg, time, addr, recvPort;
                    var val = msg[1];
                    func.(val, i);
                    nil;
                }, path).permanent_(true);
            });
        }
    }

    *trace {arg enable=true;
        //s.dumpOSC(0)
        OSCdef.trace(enable, true);
    }
}
