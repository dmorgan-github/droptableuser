/*
either repeat or alternate
    alternate = routine
    repeat = loop
values and groups of values
    both can be repeated and alternated
groups are played as subdivisions of current beat
stretch
    does not retain total bar duration at current level
    if value 1 is stretched beyond current beat then remaining items' beats are not compressed
    "1 2 [3 3 3 3 3]^2" 4 total beats beat 3 lasts 2 beats and is subdived by 5
    "1 2 [3 3 3 3 3] ~" 4 total beats beat 3 lasts 1 beat and is subdived by 5
values can be a single value or chosen from a list or generated with a function (e.g. mirror, pyramid)
*/

/*
operators:
" "    - empty space separates beats/values
~      - rest
[]     - beat sub division or group
<>     - alternating values
^n     - stretch duration - where n is a float
!n     - repeat value - where n is an integer
$      - shuffle group of values
?n     - chance of value or rest - optional probability is specified with n as an integer 0-9
#(nnn) - choose from preceeding group of values, optional weights are specified with parens where n is an integer 0-9
*/

// use the pdv parser to generate values without dur calculation
// maybe there is a way to incorporate pstep to allow for dur calculations
Pv {

    *new {
    }

    *parse {|str|
        var list, seq;
        list = Pdv.tokenize(str);
        seq = Pdv.sequence(list)
        ^Pv.route(seq);
    }

    *route {|list|

        var gate = nil;

        ^Prout({|inval|

            var parse;

            parse = {|obj, div=1, stretch=1, chance=9|

                var val, rep, shuf, choose, weights;
                var result = ();

                val = obj['val'].value;
                stretch = (obj['stretch'] ?? stretch).value.asFloat;
                chance = (obj['chance'] ?? chance).value.asInteger;
                rep = (obj['rep'] ?? 1).value.asInteger;
                choose = obj['choose'];
                weights = obj['weights'];
                if (stretch == 0.0) {"invalid stretch".postln; stretch = 1};

                // why is this here?
                if (choose == true) {
                    if (val.isSequenceableCollection) {
                        if (weights.notNil) {
                            val = val.wchoose(weights.normalizeSum);
                        }{
                            val = val.choose;
                        }
                    }
                };

                if (val.isSequenceableCollection) {
                    var size = val.size;
                    val.do({|item|
                        parse.(item, div * size.reciprocal, stretch, chance);
                    });
                }{
                    if (obj['type'] == \value) {

                        if ( (chance/9).coin.not ) {
                            val = \rest;
                        };

                        if (val.isRest) {
                            div = Rest(div);
                        };

                        rep.do({|i|
                            //inval[\g1] = gate;
                            //inval['dur'] = div * rep.reciprocal * stretch;
                            inval = val.embedInStream(inval);
                        })
                    } {
                        parse.(val, div, stretch, chance)
                    }
                };
            };

            inf.do({
                list.asArray.do({|val|
                    parse.(val);
                });
            });

            inval;
        });
    }
}

Pdv {

    *new {
    }

    *rout {|list|

        var gate = nil;

        ^Prout({|inval|

            var parse;

            parse = {|obj, div=1, stretch=1, chance=9|

                var val, rep, shuf, choose, weights;
                var result = ();

                val = obj['val'].value;
                stretch = (obj['stretch'] ?? stretch).value.asFloat;
                chance = (obj['chance'] ?? chance).value.asInteger;
                rep = (obj['rep'] ?? 1).value.asInteger;
                choose = obj['choose'];
                weights = obj['weights'];
                if (stretch == 0.0) {"invalid stretch".postln; stretch = 1};

                // why is this here?
                if (choose == true) {
                    if (val.isSequenceableCollection) {
                        if (weights.notNil) {
                            val = val.wchoose(weights.normalizeSum);
                        }{
                            val = val.choose;
                        }
                    }
                };

                /*
                if (obj['type'] == 'chord') {
                val = val.collect({|v| v['val'].value });
                obj['type'] = \value
                };
                */

                if (val.isSequenceableCollection) {
                    var size = val.size;
                    val.do({|item|
                        parse.(item, div * size.reciprocal, stretch, chance);
                    });
                }{
                    if (obj['type'] == \value) {

                        if ( (chance/9).coin.not ) {
                            val = \rest;
                        };

                        if (val.isRest) {
                            div = Rest(div);
                        };

                        rep.do({|i|
                            inval[\g1] = gate;
                            inval['dur'] = div * rep.reciprocal * stretch;
                            inval = val.embedInStream(inval);
                            gate = nil
                        })
                    } {
                        parse.(val, div, stretch, chance)
                    }
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

    *sequence {|list|

        var parse;

        parse = {|list, result|

            list.do({|item|

                var val = item['val'];
                switch(item['type'],
                    'group', {
                        var mylist = List.new;
                        mylist = parse.(val, mylist);
                        result.add(
                            // is it necessary to do this here?
                            // or would it be better to move to rout function
                            item['val'] = if (item['shuf'] == true) {
                                { mylist.asArray.scramble }
                            } {
                                mylist
                            };
                        )
                    },
                    'alt', {
                        var mylist = List.new;
                        mylist = parse.(val, mylist);
                        result.add(
                            // we need to create the routine here
                            // otherwise we end up creating it each cycle
                            // and it wouldn't sequence properly
                            item['val'] = Routine({

                                //var cnt = 0;
                                if (item['shuf'] == true) {
                                    mylist = mylist.asArray.scramble;
                                };
                                inf.do({|i|
                                    mylist.wrapAt(i).yield;
                                    //cnt = cnt + 1;
                                });
                            })
                        )
                    },
                    'chord', {
                        var mylist = List.new;
                        mylist = parse.(val, mylist);
                        result.add( item['val'] = mylist);
                    },
                    {
                        result.add( item )
                    }
                );

                /*
                if (item['type'] == \group) {
                var mylist = List.new;
                mylist = parse.(val, mylist);
                result.add(
                // is it necessary to do this here?
                // or would it be better to move to rout function
                item['val'] = if (item['shuf'] == true) {
                { mylist.asArray.scramble }
                } {
                mylist
                };
                );
                } {
                if (item['type'] == \alt) {
                var mylist = List.new;
                mylist = parse.(val, mylist);
                result.add(
                // we need to create the routine here
                // otherwise we end up creating it each cycle
                // and it wouldn't sequnce properly
                item['val'] = Routine({
                var cnt = 0;
                inf.do({|i|
                if (item['shuf'] == true) {
                mylist = mylist.asArray.scramble;
                };
                mylist.wrapAt(i).yield;
                cnt = cnt + 1;
                });
                })
                );
                }{
                result.add( item )
                }
                }
                */
            });
            result;
        };

        ^parse.(list, List.new);
    }

    *tokenize {|str|

        var exec, match, peek;
        var getNextToken;
        var hasMoreTokens;
        var spec;
        var cursor = 0;

        // as pairs
        spec = [
            'number', "^[+-]?([0-9]*[.])?[0-9]+",
            'stretch', "^\\^",
            'rep', "^\!",
            'rest', "^\~",
            'shuf', "^\\$",
            'choose', "^\#",
            'chance', "^\\?",
            'weights', "^\\([0-9]+\\)",
            '[', "^\\[",
            ']', "^\\]",
            '<', "^\<",
            '>', "^\>",
            '{', "^\{",
            '}', "^\}",
            nil, "^\\s+",
            nil, "^\,",
            nil, "^\\|" // ignore pipe character so it can be used as a visual marker

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

        peek = {
            str[cursor];
        };

        getNextToken = {
            var getNext;
            var result = nil;
            getNext = {
                if (hasMoreTokens.()) {
                    spec.pairsDo({|k, v|
                        if (result.isNil) {
                            var val = match.(v, str[cursor..]);
                            //[k, v, val].debug("match");
                            if (val.size > 0) {
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
                //token.debug("token");
                switch(token['type'],
                    // entities
                    'number', {
                        list.add( (val:token['val'].asFloat, type:\value) )
                    },
                    'rest', {
                        list.add( (val:\rest, type:\value) )
                    },
                    // modifiers
                    'stretch', {
                        var next = peek.();
                        if (next.notNil and: {next.isDecDigit}) {
                            list.last['stretch'] = getNextToken.()['val'].asFloat
                        } {
                            list.last['stretch'] = 2
                        }
                    },
                    'rep', {
                        var next = peek.();
                        if (next.notNil and: {next.isDecDigit}) {
                            list.last['rep'] = getNextToken.()['val'].asInteger;
                        } {
                            list.last['rep'] = 2;
                        }
                    },
                    'chance', {
                        var next = peek.();
                        if (next.notNil and: {next.isDecDigit} ) {
                            list.last['chance'] = getNextToken.()['val'].asInteger;
                        } {
                            list.last['chance'] = 4;
                        }
                    },
                    'shuf', {
                        list.last['shuf'] = true;
                    },
                    'choose', {
                        list.last['choose'] = true;
                    },
                    'weights', {
                        var weights = token['val'];
                        weights = weights.findRegexp("\\d+")[0][1];
                        weights = weights.asString.as(Array).collect(_.digit);
                        list.last['weights'] = weights;//.debug("weights");
                    },
                    // grouping delimiters
                    '[', {
                        var result;
                        list.add( () );
                        result = exec.(List.new);
                        list.last['val'] = result;
                        list.last['type'] = 'group'
                    },
                    ']', {
                        exit = true
                    },
                    '<', {
                        var result;
                        list.add( () );
                        result = exec.(List.new);
                        list.last['val'] = result;
                        list.last['type'] = 'alt'
                    },
                    '>', {
                        exit = true
                    },
                    '{', {
                        var result;
                        list.add( () );
                        result = exec.(List.new);
                        list.last['val'] = result;
                        list.last['type'] = 'chord'
                    },
                    '}', {
                        exit = true
                    }
                );
            });

            list;
        };

        ^exec.(List.new);
    }

    *parse {|str|
        var list, seq;
        list = Pdv.tokenize(str);
        seq = Pdv.sequence(list)
        ^Pdv.rout(seq);
    }
}

