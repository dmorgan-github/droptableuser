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

Pdv {

    *new {
    }

    *rout {|list|

        var gate = nil;

        ^Prout({|inval|

            var parse;

            parse = {|obj, div=1, stretch=1|

                var val, rep, shuf;
                var result = ();

                val = obj['val'].value;
                stretch = (obj['stretch'] ?? stretch).value.asFloat;
                rep = (obj['rep'] ?? 1).value.asInteger;

                if (val.isSequenceableCollection) {
                    var size = val.size;
                    val.do({|item|
                        parse.(item, div * size.reciprocal * stretch, stretch);
                    });
                }{

                    if (obj['type'] == \value) {

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
                        parse.(val, div, stretch)
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
                var stretch = item['stretch'] ?? 1;
                var rep = item['rep'] ?? 1;
                if (item['type'] == \group) {
                    var mylist = List.new;
                    mylist = parse.(val, mylist);
                    result.add(
                        item['val'] = if (item['shuf'] == true) {
                            { mylist.asArray.scramble }
                        } {
                            if (item['choose'] == true) {
                                { mylist.asArray.choose }
                            } {
                                mylist
                            }
                        };
                    );
                } {
                    if (item['type'] == \alt) {
                        var mylist = List.new;
                        mylist = parse.(val, mylist);
                        result.add(

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
            });
            result;
        };

        ^parse.(list, List.new);
    }

    *tokenize {|str|

        var exec, match;
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
                    'number', {
                        list.add( (val:token['val'].asFloat, type:\value) )
                    },
                    'rest', {
                        list.add( (val:\rest, type:\value) )
                    },
                    // modifiers
                    'stretch', {
                        list.last['stretch'] = getNextToken.()['val'].asFloat
                    },
                    'rep', {
                        list.last['rep'] = getNextToken.()['val'].asInteger;
                    },
                    'shuf', {
                        list.last['shuf'] = true;
                    },
                    'choose', {
                        list.last['choose'] = true;
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

/*
Pdv {

    /*
    TODO:
    #1 3 4 5# // equal weight random
    <[4 5 1 4 3]$ [3 2 1]$> // random in alternating sequence
    "[1 2 3].mirror2" // generative functions
    */

    *new {
    }

    *parse {|str|
        var list = Pdv.tokenize(str);
        ^Pdv.rout(list);
    }

    *rout {|list|

        var gate = nil;

        ^Prout({|inval|

            var parse;

            parse = {|obj, div=1|

                var val, stretch, rep, shuf;
                var result = ();

                val = obj['val'].value;//.debug(\val);
                stretch = (obj['stretch'] ?? 1.0).value.asFloat;
                rep = (obj['rep'] ?? 1).value.asInteger;
                shuf = obj['shuf'];

                if (val.isSequenceableCollection) {
                    var size = val.size;
                    rep.do({
                        if (shuf == true) {
                            val = val.scramble;
                        };
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
                        inval = val.embedInStream(inval);
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

    *tokenize  {|str|

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
            \shuf, "^\\$",
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
                    \shuf, {
                        list.last['shuf'] = true;
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
                        list.last['val'] = Ppatlace(result.collect({|o|
                            // TODO: bug - losing additional modifiers
                            // for the collection
                            if (o['val'].isCollection) {
                                o['val']
                            } {
                                o['val'].asFloat
                            }
                        }), inf).asStream;
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
*/
