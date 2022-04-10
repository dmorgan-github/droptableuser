(
Fdef('dialects/aeg', {|val, obj|

    val.asDict.pairsDo({|k, v|
        switch(k,
            \a, {obj.set(\atk, v)},
            \d, {obj.set(\dec, v)},
            \s, {obj.set(\suslevel, v)},
            \r, {obj.set(\rel, v)},
            \ac, {obj.set(\atkcurve, v)},
            \dc, {obj.set(\deccurve, v)},
            \rc, {obj.set(\relcurve, v)}
        )
    });
    "aeg".debug("dialects");
});

Fdef('dialects/feg', {|val, obj|

    val.asDict.pairsDo({|k, v|
        switch(k,
            \a, {obj.set(\fatk, v)},
            \d, {obj.set(\fdec, v)},
            \s, {obj.set(\fsuslevel, v)},
            \r, {obj.set(\frel, v)},
            \ac, {obj.set(\fatkcurve, v)},
            \dc, {obj.set(\fdeccurve, v)},
            \rc, {obj.set(\frelcurve, v)},
            \c, {obj.set(\cutoff, v)},
            \q, {obj.set(\res, v)},
        )
    });
    "feg".debug("dialects");
});

)