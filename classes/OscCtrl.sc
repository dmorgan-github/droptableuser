Mixer {

    classvar <server, <page, <num;

    *initClass {
        page = 'mixer';
        num = 16;
        StartUp.add({
            server = NetAddr(App.touchoscserver, App.touchoscport);
        });
    }

    *channel {|index, node|

        var warn = {
            if (index < 1) {
                "channels start from 1".warn
            }
        }.();

        var key = node.key;
        var faderPath = "/%/fader%".format(page, index).asSymbol;
        var faderFunc = {|val|
            var vol = val[0];
            node.vol = vol;
        };
        var faderVal = node.vol;
        var isMute = node.isMonitoring.not.asInteger;

        var mutePath = "/%/mute%".format(page, index).asSymbol;
        var muteFunc = {|val|
            var monitor = val[0];
            monitor = monitor.asBoolean.not;
            if (monitor) {
                node.play;
            } {
                node.stop;
            }
        };

        var labelPath = "/%/label%".format(page, index).asSymbol;

        server.sendMsg(faderPath, faderVal);
        server.sendMsg(mutePath, isMute);
        server.sendMsg(labelPath, key);

        OscCtrl.path(faderPath, faderFunc);
        OscCtrl.path(mutePath, muteFunc);
    }
}


TwisterOsc {

    classvar <server, num, <>page;

    *new {|tabs|

        var update = {|selected|
            if (selected < tabs.size) {
                num.do({|i|
                    RotaryOsc(i);
                });
                tabs[selected].value.();
            }
        };

        num.do({|i|
            var index = i+1;
            var path = "/%/nodes/%/1".format(page, index).asSymbol;
            var func = {|val|
                var selected = num-index;
                val = val[0];
                if (val.asInteger == 1) {
                    update.(selected)
                }
            };
            OscCtrl.path(path, func)
        });

        tabs.do({|val, num|
            var name = val.key;
            var path = "/%/nodelabel%".format(page, num).asSymbol;
            server.sendMsg(path, name);
        });
    }

    *initClass {
        page = 'twister';
        num = 16;
        StartUp.add({
            server = NetAddr(App.touchoscserver, App.touchoscport);
        });
    }
}

RotaryOsc {

    classvar <server;

    *new {|num, label, setfunc, getfunc, spec|

        var page = 'twister';
        var valpath = "/%/val%".format(page, num).asSymbol;
        var labelpath = "/%/label%".format(page, num).asSymbol;
        var path = "/%/rotary%".format(page, num).asSymbol;

        if (label.isNil) {
            server.sendMsg(valpath, "");
            server.sendMsg(labelpath, "");
            server.sendMsg(path, 0);
        }{
            var val;
            spec = if (spec.isNil) {
                spec = ControlSpec.specs[label.asSymbol];
                if (spec.isNil) {
                    spec = ControlSpec(0, 1, \lin, 0, 0);
                };
                spec;
            };

            OscCtrl.path(path, {arg msg;
                var val = msg[0];
                val = spec.map(val);
                setfunc.(val);
                val = val.trunc(0.001);
                server.sendMsg(valpath, val);
            });
            server.sendMsg(labelpath, label);

            val = getfunc.() ?? spec.default;
            val = val.trunc(0.001);
            server.sendMsg(valpath, val);

            val = spec.unmap(val);
            server.sendMsg(path, val);
        }
    }

    *initClass {

        StartUp.add({
            server = NetAddr(App.touchoscserver, App.touchoscport);
        });
    }
}


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
        OSCdef.trace(enable);
    }
}