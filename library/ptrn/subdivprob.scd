(
func: {|mask, sub, subprob|

    Prout({|inval|

        var step;
        mask = mask.asStream;
        sub = sub.asStream;
        if (subprob.isNil) {
            subprob = Pn(1);
        };
        subprob = subprob.asStream;

        inf.do({
            step = mask.next(inval);
            if (step.isNil) {
                inval = nil.embedInStream(inval);
            } {
                if (step.isRest or: { step.coin.not } ) {
                    inval = Rest(1).embedInStream(inval);
                } {
                    var div = sub.next(inval);
                    var prob = subprob.next(inval);
                    div.do({
                        var val = 1/div;
                        if (prob.coin.not) {
                            val = Rest(val)
                        };
                        inval = (val).embedInStream(inval);
                    });
                };
            }
        })
    })
}
)