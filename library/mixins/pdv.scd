(
Pdef(\pdv, {

    var key = currentEnvironment['pdv/key'] ?? {\degree};
    //key.debug("pdv key");

    Plazy({|evt|

        var cycle = evt[\cycle] ?? 0;
        var list = evt[key].value(cycle) ?? { [] };
        //list.debug("pdv list");

        Pbind(
            \pdvsize, list.size,
            \pdvkey, key,

            [key, \dur], Prout({|inval|

                var parse = {arg seq, div=1;
                    var myval = seq;
                    // if the value is a function don't unpack it here
                    if (myval.isKindOf(Function).not) {
                        if (myval.isKindOf(Association)) {
                            div = div * myval.key.asFloat;
                        };
                        myval = myval.value;
                    };

                    if (myval.isArray) {
                        var myseq = myval;
                        var mydiv = 1/myseq.size * div;
                        var stream = CollStream(myseq);
                        var val = stream.next;
                        while ({val.isNil.not},
                            {
                                parse.(val, mydiv);
                                val = stream.next
                            }
                        );
                    } {
                        if (myval.isRest) {
                            myval = Rest();
                            div = Rest(div);
                        } {
                            if (myval.isKindOf(Function)) {
                                // if the value is a Function
                                // unpack it and use as-is
                                // this allows us to configure chords
                                // and multi-channel expansion
                                myval = myval.value;
                            } {
                                if (myval.isNil) {
                                    div = nil;
                                }
                            }
                        };
                        inval = [myval, div].embedInStream(inval);
                    }
                };

                var pseq = CollStream(list.asArray);
                var item;
                var val = pseq.next;
                while({val.isNil.not}, {
                    parse.(val);
                    val = pseq.next;
                });
                inval;
            })
        ).repeat
    })
})
)