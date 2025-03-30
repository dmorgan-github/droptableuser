Pdv2 {

    *new {
    }

    *rout {|list|

        var gate = nil;

        ^Prout({|inval|

            var parse;

            parse = {|obj, div=1, stretch=1, chance=9, rep=1, ischord=false, list|

                var val, shuf, choose, weights;
                var legato, vel, kv;
                val = obj['val'].value;
                stretch = (obj['stretch'] ?? stretch).value.asFloat;
                chance = (obj['chance'] ?? chance).value.asInteger;
                rep = (obj['rep'] ?? rep).value.asInteger;
                choose = obj['choose'];
                weights = obj['weights'];
                legato = obj['legato'];
                vel = obj['vel'];
                kv = obj['kv'];
                ischord = if (ischord or: { obj['type'] == 'chord' }) {true }{false};
                if (ischord) {
                    if (list.isNil) {
                        list = List.new;
                        // we don't know the size of the chord
                        // since inner nodes can also be chords
                        // resulting in more items than the outer array
                        // so we add a token at the end of the list
                        // to know when all the chord items have been
                        // accumulated and we can embed the result
                        val = val.copy.add( (type: 'chordend') )
                    }
                };
                if (stretch == 0.0) {"invalid stretch".postln; stretch = 1};

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
                    div = if (ischord) { div }{ div * size.reciprocal };
                    val.do({|item|
                        parse.(item, div, stretch, chance, rep, ischord, list);
                    });
                }{
                    if (obj['type'] == \value or: {obj['type'] == 'chordend'}) {

                        var embed = true;

                        if ( chance.coin.not ) {
                            val = \rest;
                        };

                        if (val.isRest) {
                            div = Rest(div);
                        };

                        if (ischord) {
                            //embed = false;
                            //if (val.notNil) {
                            //    list.add(val);
                            //};
                            // we are within a chord - either we are resolving
                            // the items within the chord or we are done
                            // and can output the result
                            if ( obj['type'] == 'chordend') {
                                // done resolving items within the chord
                                // we can embed the result
                                embed = true;
                                val = list.asArray
                            } {
                                embed = false;
                                list.add(val);
                            }
                        };

                        if (embed) {
                            rep.do({|i|
                                inval[\g1] = gate;
                                inval['dur'] = div * rep.reciprocal * stretch;
                                if (legato.notNil) {
                                    inval['legato'] = legato;
                                };
                                if (vel.notNil) {
                                    inval['vel'] = vel;
                                };
                                inval = val.embedInStream(inval);
                                gate = nil
                            })
                        }
                    } {
                        parse.(val, div, stretch, chance, rep, ischord, list)
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

            });
            result;
        };

        ^parse.(list, List.new);
    }

    *tokenize {|str|

        var exec, match, peek;
        var getNextToken;
        var hasMoreTokens;
        var fromHexString;
        var spec;
        var cursor = 0;

        // as pairs
        spec = [
            'number', "^[+-]?([0-9]*[.])?[0-9]+",
            'stretch', "^\\^",
            'legato', "^_[0-9a-fA-F]{1,2}",
            'velocity', "^\\*[0-9a-fA-F]{1,2}",
            'kv', "^;[a-zA-Z]+=[0-9a-fA-f]{1,2}",
            'rep', "^\![0-9]+",
            'rest', "^\~",
            'shuf', "^\\$",
            'choose', "^\#",
            'chance', "^^\\?[0-9a-fA-f]{0,2}",
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

            if (result.isNil and: {cursor < str.size}) {
                "unexpected token %".format(str[cursor]).throw
            };
            result;
        };

        fromHexString = {|str|
            var digits;
            digits = str.collectAs({|chr| chr.digit.min(15) }, Array);
            if(digits.size == 1, { digits = digits.dupEach(2) });
            digits = digits[0] * 16 + digits[1];
            digits;
        };

        exec = {|list|

            var exit = false;
            while ({ hasMoreTokens.() and: { exit.not } }, {
                var token = getNextToken.();

                if (token.notNil) {
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
                            var val = token['val'];
                            val = val[1..];
                            val = val.findRegexp("\\d+")[0][1];
                            list.last['rep'] = val.asInteger;
                        },
                        'chance', {
                            var val = token['val'];
                            val = val[1..];
                            if (val.size > 0) {
                                val = fromHexString.(val);
                            } {
                                val = 127;
                            };
                            list.last['chance'] = val/255;
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
                        'legato', {
                            var val = token['val'];
                            val = val[1..];
                            val = fromHexString.(val);
                            list.last['legato'] = val/255;
                        },
                        'velocity', {
                            var val = token['val'];
                            val = val[1..];
                            val = fromHexString.(val);
                            list.last['vel'] = val/255;
                        },
                        'kv', {
                            var key, val, last;
                            var kv = token['val'];
                            kv = kv[1..];
                            kv = kv.split($=);
                            key = kv[0];
                            val = kv[1];
                            val = fromHexString.(val);
                            val = val/255;
                            last = list.last;
                            if (last['kv'].isNil) {
                                last['kv'] = Dictionary();
                            };
                            last['kv'].put(key.asSymbol, val)
                            //list.last[key.asSymbol] = val;
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
                }
            });

            list;
        };

        ^exec.(List.new);
    }

    *parse {|str|
        var list, seq;
        if (str.isNil) {
            "pdv input is nil".throw;
        }{
            list = Pdv2.tokenize(str.stripWhiteSpace);
            seq = Pdv2.sequence(list);
            ^Pdv2.rout(seq)
        }
    }
}

