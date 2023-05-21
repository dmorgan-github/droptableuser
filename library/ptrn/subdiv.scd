Spec.add(\k, ControlSpec(1, 8, 'lin', 0, 1, units: "dur"));
Spec.add(\n, ControlSpec(1/8, 8, 'lin', 1/8, 1, units: "dur"));
Spec.add(\x, ControlSpec(0, 3, 'lin', 1, 0, units: "xy"));
Spec.add(\y, ControlSpec(0, 3, 'lin', 1, 0, units: "xy"));

(
func: {

    var seq, pattern;

    var args = [
        'd' -> 'degree',
        'o' -> 'octave',
        'm' -> 'mtranspose',
        'h' -> 'harmonic',
        'l' -> 'legato',
        'p' -> 'prob',
        'v' -> 'vel',
        'g' -> 'gain'
    ];

    pattern = Plazy({|evt|

        var ptrns, myargs;
        myargs = args ++ (evt['keys'].asArray);
        ptrns = myargs.collect({|val|

            var inkey, outkey, switchkey;

            if (val.isKindOf(Association)) {
                inkey = val.key;
                outkey = val.value;
            }{
                inkey = val;
                outkey = val;
            };

            switchkey = "%_seq".format(inkey).asSymbol;

            [outkey, Pbinop(
                \wrapAt,
                Pfuncn({|evt|
                    var val = evt[inkey];
                    if (val.isNil) {
                        val = Event.default.use({ currentEnvironment[outkey] });
                        if (val.isNil) {
                            var spec;
                            var instr = evt['instrument'];
                            if (instr.notNil) {
                                var specs = SynthDescLib.global[instr].specs;
                                if (specs.notNil) {
                                    spec = specs[outkey];
                                    if (spec.isNil) {
                                        Spec.specs[outkey];
                                    }
                                }
                            };
                            if (spec.notNil) {
                                val = spec.default;
                            } {
                                val = 1;
                            }
                        };
                    };
                    val.asArray
                }),
                Pswitch1(
                    [
                        Pkey('subcount'),
                        Pkey('durcount'),
                        Pkey('xy'),
                        Pfunc({|evt|
                            evt[inkey].size.rand
                        })
                    ],
                    Pfunc({|evt|
                        var val = evt[switchkey];
                        if (val.notNil) {val} {0};
                    }),
                    inf
                )
            )]
        });

        Pbind(*ptrns.flatten)

    }).repeat;

    seq = Pbind(
        #[\dur, \durcount, \subcount], Prout({|inval|
            var durcount = 0;
            var subcount = 0;
            var list = List.new;
            inf.do({|i|

                var k, n, nextk, nextn;

                k = inval['k'] ?? [1];
                n = inval['n'] ?? [1];

                nextk = k.asArray.wrapAt(durcount).max(1);
                nextn = n.asArray.wrapAt(durcount);

                nextk.do({|j|
                    list.add(nextn/nextk);
                });

                list.do({|val|
                    if (val <= 0) {
                        val = 1;
                    };
                    inval = [val, durcount, subcount].yield;
                    subcount = subcount + 1;
                });

                durcount = durcount + 1;
                list.clear;
            });
            inval;
        }),
        \xpos, Pbinop(
            \wrapAt,
            Pfunc({|evt|
                var x = evt['x'] ?? { [0] };
                x.asArray;
            }),
            Pswitch1(
                [
                    Pkey('subcount'),
                    Pkey('durcount')
                ],
                Pfunc({|evt|
                    var val = evt['x_seq'];
                    if (val.notNil) {val} {0};
                }),
            )
        ),
        \ypos, Pbinop(
            \wrapAt,
            Pfunc({|evt|
                var y = evt['y'] ?? { [0] };
                y.asArray;
            }),
            Pswitch1(
                [
                    Pkey('subcount'),
                    Pkey('durcount')
                ],
                Pfunc({|evt|
                    var val = evt['y_seq'];
                    if (val.notNil) {val} {0};
                }),
            )
        ),
        \xy, Pfunc({|evt|
            var x, y, lenx, leny, num;
            lenx = evt['lenx'] ?? {4};
            leny = evt['leny'] ?? {4};
            x = evt['xpos'].mod(lenx);
            y = evt['ypos'].mod(leny);
            num = (leny * y) + (x);
            num;
        })
    );

    Pchain( pattern, seq )
    .pfilter(\prob, Pfunc({|evt|
        if (evt['prob'].coin) {1}{Rest(1)}
    }))
}
)
