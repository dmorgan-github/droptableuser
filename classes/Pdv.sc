Pdv {

    /*
    would like to support
    "0 2 <[1 3] 1>"
    "0 2 [1, 3]!<2, 3>"
    "0 2 [1, [3 2 <1 0>]]!<2, 3>^<2, 4>"
    "0 2 [4!2^2 r <5 6>] -3^<2 3 4>"
    "0^2 1 [4!2^1.5 5](<mirror2,pyrmaid_7>)"
    */

    *new {
    }

    *parse {|str|
        var list = Pdv.compile(str);
        ^Pdv.rout(list);
    }

    *rout {|list|

        var gate = nil;

        ^Prout({|inval|

            var parse;

            parse = {|obj, div=1|

                var result = ();
                var val = obj['val'];//.debug(\val);
                var stretch = (obj['stretch'] ?? 1.0).value.asFloat;
                var rep = (obj['rep'] ?? 1).value.asInteger;

                if (val.isSequenceableCollection) {
                    var size = val.size;
                    rep.do({
                        val.do({|item|
                            parse.(item, div * size.reciprocal * stretch);
                        });
                    })
                }{
                    if (val.isRest) {
                        div = Rest(div);
                    };

                    rep.do({|i|
                        inval[\g1] = gate;
                        inval['dur'] = div * rep.reciprocal * stretch;
                        inval = val.value.embedInStream(inval);
                        gate = nil
                    })
                };
            };

            inf.do({
                gate = true;
                list.asArray.do({|val|
                    parse.(val);
                });
            });

            inval;
        });
    }

    *compile  {|str|

        var exec, match;
        var getNextToken;
        var hasMoreTokens;
        var spec;
        var cursor = 0;

        // as pairs
        spec = [
            \number, "^[+-]?([0-9]*[.])?[0-9]+",
            \stretch, "^\\^",
            \rep, "^\!",
            \rest, "^\~",
            '[', "^\\[",
            ']', "^\\]",
            '<', "^\<",
            '>', "^\>",
            nil, "^\\s+",
            nil, "^\,",

        ];

        hasMoreTokens = {
            cursor < str.size;
        };

        match = {|regex, str|
            var val = nil;
            var m = str.findRegexp(regex);
            if (m.size > 0) {
                val = m[0][1];
                cursor = cursor + val.size;
            };
            val;
        };

        getNextToken = {
            var getNext;
            var result = nil;
            getNext = {
                if (hasMoreTokens.()) {
                    spec.pairsDo({|k, v|
                        if (result.isNil) {
                            var val = match.(v, str[cursor..]);
                            if (val.notNil) {
                                if (k.isNil) {
                                    getNext.()
                                }{
                                    result = (
                                        type: k,
                                        val: val
                                    );
                                }
                            }
                        }
                    });
                };
            };

            getNext.();
            if (result.isNil) {
                "unexpected token %".format(str[cursor]).throw
            };
            result;
        };

        exec = {|list|

            var exit = false;
            while ({ hasMoreTokens.() and: { exit.not } }, {
                var token = getNextToken.();
                switch(token['type'],
                    // entities
                    \number, {
                        list.add( (val:token['val'].asFloat) )
                    },
                    \rest, {
                        list.add( (val:\rest) )
                    },
                    // modifiers
                    \stretch, {
                        list.last['stretch'] = getNextToken.()['val'].asFloat
                    },
                    \rep, {
                        list.last['rep'] = getNextToken.()['val'].asInteger;
                    },

                    // grouping delimiters
                    '[', {
                        var result;
                        list.add( () );
                        result = exec.(List.new);
                        list.last['val'] = result;
                    },
                    ']', {
                        exit = true
                    },
                    '<', {
                        var result;
                        list.add( () );
                        result = exec.(List.new);
                        list.last['val'] = Ppatlace(result.collect({|o| o['val'].asFloat }), inf).asStream;
                        list.last['func'] = 'alt'
                    },
                    '>', {
                        exit = true
                    }
                );
            });

            list;
        };

        ^exec.(List.new);
    }
}
