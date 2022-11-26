(
func: {

    var seq = EventPatternProxy();
    seq.source = Pspawner({|sp|

        var stepcount = 0;
        var durcount = 0;
        var subcount = 0;
        var currentdur, currentsub;
        var step;

        var steps, durs, subs;
        var a, b, c, tatum;
        var data;

        inf.do({

            data = sp.event;
            steps = data['steps'] ?? [1];
            durs = data['durs'] ?? [1];
            subs = data['subs'] ?? [1];
            a = data['a'] ?? [];
            b = data['b'] ?? [];
            c = data['c'] ?? [];
            tatum = data['tatum'] ?? 1;

            step = steps.wrapAt(stepcount);
            step.do({|i|

                currentdur = durs.wrapAt(durcount);
                currentsub = subs.wrapAt(subcount);

                currentsub.do({|j|
                    var dur = currentdur/currentsub;
                    if (i == 0 and: {j == 0} ) {

                        a.do({|v|
                            sp.par(v.next(Event.default).repeat(1))
                        });

                    };
                    if (j == 0) {
                        b.do({|v|
                            sp.par(v.next(Event.default).repeat(1))
                        });
                    };

                    c.do({|v|
                        sp.par(v.next(Event.default).repeat(1))
                    });

                    sp.wait(dur * tatum)
                });

                durcount = durcount + 1;
                subcount = subcount + 1;
            });

            stepcount = stepcount + 1;
        });
    });

    seq;
},
doc: "
~seq = Module('device/abc').();
~seq.play
~seq.stop

~seq.set('steps', [1, 2, 3, 1].mirror1)
~seq.set('durs', [1, 2, 4, 1].scramble.mirror1)
~seq.set('subs', [1, 2, 3, 4].mirror1)
~seq.set('tatum', 0.5)
(
  // don't forget asStream
  ~seq.set(
    'a', [~bass.asStream],
    'b', [~fd.asStream],
    'c', []
  )
)
"
)


