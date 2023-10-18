Layer {

    var <>instr;
    var <>scenes;

    *new {
        ^super.new.prLayerInit;
    }

    prLayerInit{
        scenes = [Pbind()];
        instr = InstrProxy()
    }
}


Layers {

    var <layers;
    var <sends;
    var <player;

    *new {
        var res;
        res = super.new.prLayersInit;
        ^res;
    }
  
    at {|num|
        var layer;
        layer = layers[num];
        ^layer
    }

    put {|num, ptrns|
        ptrns = ptrns.asArray.collect({|p, i|
            var key = "layer%_%".format(num, i).asSymbol;
            Pdef(key, p)
        });
        layers.put(num, ptrns);
    }

    /*
    (
var numlayers = 2;
var numscenes = 3;
var vals =  (1/numscenes).pow( (0..(numlayers-1)) );
var combos = numscenes ** numlayers;
combos.do({|i|
    var myvals = i * vals;
    myvals.mod(numscenes).floor.postln;
})
)
*/

    /*
    indexPlay {|index|
        var numlayers = this.layers.size;
        // adding an additional scene for silence
        var numscenes = 3 + 1;
        var vals =  (1/numscenes).pow( (0..(numlayers-1)) );
        var combos = numscenes ** numlayers;
        var myvals = index * vals;
        myvals = myvals.mod(numscenes).floor.collect({|v| if (v == (numscenes-1)) {\} {v} }).debug("scenes");
        this.play(myvals);        
    }
    */

    /*
    play {|scenes|

        var ptrn;
        ptrn = scenes.collect({|v, i|
            if (v.isRest) {
                Pn(Event.silent)
            } {
                var l = layers.wrapAt(i);
                if (v >= l.scenes.size) {
                    Pn(Event.silent)
                } {
                    l.scenes[v] <> layers.wrapAt(i).instr
                }
            }
        });
        player.source = Ppar(ptrn);
        player.play
    }
    */

    play {|indexes|

        var ptrn;
        indexes.debug("indexes...");
        ptrn = indexes.collect({|v, i|
            if (v.isRest) {
                Pn(Event.silent)
            }{
                layers[i].asArray.wrapAt(v)
            }
        });
        player.source = Ppar(ptrn);
        player.play
    }

    stop {
        player.stop
    }

    send {|...pairs|

        var num1 = pairs.size/2;
        var num2 = sends.size;
        var i=0;
        if (num2 > num1) { 
            num2.reverseDo({|n|
                if (n > num1) {
                    sends[n].clear;
                    sends.removeAt(n);
                }
            })
        };

        pairs.keysValuesDo ({|k, v|

            var vals, fx, fxindex = 50;
            var instrs;
            var send = sends.at(i);
            if (send.isNil) {
                send = DMNodeProxy().play;
                sends.put(i, send);
            };

            vals = k.stripWhiteSpace.split($\ );
            instrs = send.objects.indices.select({|v| v < fxindex });

            if (instrs.size > v.size) {
                instrs.size.reverseDo({|k|
                    if (k > v.size) {
                        send.removeAt(k)
                    }
                })
            };
            v.do({|j, k|
                send.put(k, \mix -> { layers[j].node.ar })
            });

            fx = send.objects.indices.select({|v| (v >= fxindex).and(v < 100) });
            if (fx.size > vals.size) {
                fx.size.reverseDo({|n|
                    if ((fxindex + n) > vals.size) {
                        send.removeAt(fxindex + n)
                    }
                })
            };
            // TODO: don't reload if same fx
            vals.postln;
            vals.do({|v, i|
                send.fx(fxindex + i, v.asSymbol);
            }); 

            i = i + 1;
        })
    }

    /*
    prParse {|str, instr|

        var lines = str.stripWhiteSpace.split($\n);
        var synth = lines[0];
        var ptrns = lines[1..];

        instr +> synth;
        ptrns.do({|p, i|
            var pairs = p.split($\ );
            var key = pairs[0].asSymbol;
            var val = pairs[1..].join($\ ).asString;
            if (i == 0) {
                val = val.pdv
            } {
                val = val.interpret
            };
            instr.set(key, val);
        });
    }
    */

    /*
    prEnsureLayer {|num|
        var layer = layers.at(num);
        if (layer.isNil) {
            layer = Layer();
            layers.put(num, layer);
        };
        ^layer;
    }
    */

    prLayersInit {
        layers = Order();
        sends = Order();
        player = EventPatternProxy();
    }
}
