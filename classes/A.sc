// adapted from https://github.com/schollz/mx.synths/blob/main/lib/arp.lua#L207-L378
// https://www.ableton.com/en/manual/live-midi-effect-reference/

A {
    *up {|s|
        ^s.sort
    }

    *down {|s|
        // down
        // 1 2 3 4 5 becomes
        // 5 4 3 2 1
        //var s = [1, 2, 3, 4, 5];
        ^s.sort.reverse
    }

    *updown {|s|
        // up-down
        // 1 2 3 4 5 becomes
        // 1 2 3 4 5 4 3 2
        //var s = [1, 2, 3, 4, 5];
        ^s.sort.mirror1;
    }

    *downup {|s|
        // down-up
        // 1 2 3 4 5 become
        // 5 4 3 2 1 2 3 4
        //var s = [1, 2, 3, 4, 5];
        ^s.sort.reverse.mirror1;
    }

    *converge {|s|
        // converge
        // 1 2 3 4 5 becomes
        // 5 1 4 2 3
        //var s = [1, 2, 3, 4, 5];
        var s_reverse = s.sort.reverse;
        var s2 = List.new;

        s_reverse.do({|n, i|
            if (s2.size < s.size) {
                s2.add(n);
                if (s2.size != s.size) {
                    s2.add(s_reverse[s_reverse.size-(i+1)]);
                }
            };
        });

        ^s2.asArray
    }


    // not sure this is correct
    // i think it should be more like
    // 3 2 4 1 5
    *diverge {|s|
        // 1 2 3 4 5 becomes
        // 1 5 2 4 3
        //var s = [1, 2, 3, 4, 5];
        var s_reverse = s.sort.reverse;
        var s2 = List.new;

        s.do({|n, i|
            if (s2.size < s.size) {
                s2.add(n);
                if (s2.size != s.size) {
                    s2.add(s[s.size-(i+1)]);
                }
            };
        });

        ^s2.asArray
    }

    *convergediverge {|s|
        // 1 2 3 4 5 becomes
        // 5 1 4 2 3 2 4 1
        //var s = [1, 2, 3, 4, 5];
        var s_reverse = s.sort.reverse;
        var s2 = List.new;

        s_reverse.do({|n, i|
            if (s2.size < s_reverse.size) {
                s2.add(n);
                if (s2.size != s_reverse.size) {
                    s2.add(s_reverse[s_reverse.size-(i+1)]);
                }
            };
        });

        forBy(s2.size-2, 0, -1, {|i|
            if (i > 0 and: {i < s2.size}) {
                s2.add(s2[i]);
            }
        });

        ^s2.asArray
    }


    *divergeconverge {|s|
        // 1 2 3 4 5 becomes
        // 1 5 2 4 3 4 2 5
        //var s = [1, 2, 3, 4, 5];
        var s_reverse = s.sort.reverse;
        var s2 = List.new;

        s.do({|n, i|
            if (s2.size < s.size) {
                s2.add(n);
                if (s2.size != s.size) {
                    s2.add(s[s.size-(i+1)]);
                }
            };
        });
        forBy(s2.size-2, 0, -1, {|i|
            if (i > 0 and: {i < s2.size}) {
                s2.add(s2[i]);
            }
        });

        ^s2.asArray
    }

    *pinkyup {|s|
        // 1 2 3 4 5 becomes
        // 1 5 2 5 3 5 4 5
        //var s = [1, 2, 3, 4, 5];
        var s_reverse = s.sort.reverse;
        var s2 = List.new;

        s.do({|n, i|
            if (i < (s.size-1)) {
                s2.add(n);
                s2.add(s[s.size-1]);
            };
        });

        ^s2.asArray
    }


    *pinkyupdown {|s|
        // 1 2 3 4 5 becomes
        // 1 5 2 5 3 5 4 5 4 5 3 5 2 5
        //var s = [1, 2, 3, 4, 5];
        var s_reverse = s.sort.reverse;
        var s2 = List.new;

        s.do({|n, i|
            if (i < (s.size-1) ) {
                s2.add(n);
                s2.add(s[s.size-1]);
            };
        });

        s_reverse.do({|n, i|
            if (i > 0 and: { i < (s_reverse.size-1) } ) {
                s2.add(n);
                s2.add(s[s.size-1]);
            }
        });

        ^s2.asArray
    }

    *thumbup {|s|
        // 1 2 3 4 5 becomes
        // 1 2 1 3 1 4 1 5
        //var s = [1, 2, 3, 4, 5];
        var s_reverse = s.sort.reverse;
        var s2 = List.new;

        s.do({|n, i|
            if (i > 0) {
                s2.add(s[0]);
                s2.add(n);
            };
        });

        ^s2.asArray
    }

    *thumbupdown {|s|
        // 1 2 3 4 5 becomes
        // 1 2 1 3 1 4 1 5 1 4 1 3 1 2
        //var s = [1, 2, 3, 4, 5];
        var s_reverse = s.sort.reverse;
        var s2 = List.new;

        s.do({|n, i|
            if (i > 0) {
                s2.add(s[0]);
                s2.add(n);
            };
        });

        s_reverse.do({|n, i|
            if (i > 0 and: { i < (s_reverse.size-1)} ) {
                s2.add(s[0]);
                s2.add(n);
            }
        });

        ^s2.asArray
    }

    *psin {|dur, lo=0, hi=1|
        dur = dur * 0.5;
        ^Pseg([0, 1, 0].pseq, [dur, dur, 0].pseq, \sine, inf).linlin(0, 1, lo, hi)
    }

    *psaw {|dur, lo=0, hi=1|
        ^Pseg([0, 1].pseq, [dur, 0].pseq, \lin, inf).linlin(0, 1, lo, hi)
    }

    *ptri {|dur, lo=0, hi=1|
        dur = dur * 0.5;
        ^Pseg([0, 1, 0].pseq, [dur, dur, 0].pseq, \lin, inf).linlin(0, 1, lo, hi)
    }


    // A.randseq(32, 0.1, seed:5597)
    *randseq {|len=16, density=0.3, min=0, max=7, seed|
        /*
        Array.fill(32, { 1.0.rand2.linlin(-1, 1, 0, 5).round }).plot
        Array.fill(32, { 1.0.linrand.linlin(0, 1, 0, 5).round }).plot
        Array.fill(32, { 1.0.bilinrand.linlin(-1, 1, 0, 5).round }).plot
        Array.fill(32, { 1.0.sum3rand.linlin(-1, 1, 0, 5).round }).plot
        Array.fill(32, { exprand(0.001, 1.0).linlin(0.1, 1, 0, 5).round }).plot
        */

        var result;
        var den = (len * density).floor.asInteger;

        thisThread.randSeed = seed ?? { 1000000.rand.debug(\seed) };

        result = {
            {|v|
                var index = v.indicesOfEqual(\).choose;
                var val = rrand(min, max);
                v.wrapPut (index, val)
            }
        }
        .dup(den)
        .inject(\.dup(len), {|s, f| f.(s) } );

        ^result;
    }


    // A.rout(32, Array.fill(32, { (0..12).choose  }), [0, 2], [4])
    *rout {|size=32, vals, startvals, lenvals|

        var phase = 0;
        var done = false;
        var result = List.new;

        vals = vals ?? [0];
        startvals = startvals ?? [0];
        lenvals = lenvals ?? [1];

        while({done.not}, {
            var start, len;
            start = startvals.wrapAt(phase);
            len = lenvals.wrapAt(phase);

            vals.wrapAt( (start..(start+len-1)) ).do({|val, i|
                if (result.size >= size) {
                    done = true;
                } {
                    result.add(val);
                }
            });
            phase = phase + 1;
        });

        ^result.asArray
    }

    // credit: https://scsynth.org/t/do-not-returning-array/6416/14
    // A.swap_sort_steps(['a', 'b', 'c', 'd'])
    // returns  [ [ a, b, c, d ], [ b, a, d, c ], [ b, d, a, c ], [ d, b, c, a ], [ d, c, b, a ] ]
    *swap_sort_steps  {|collection|
        var size = collection.size;
        var swapConsequtiveIndexes = {|from, to|
            (from..to).clump(2).collect{|p| p.reverse }.flat
        };
        var indexesEven = swapConsequtiveIndexes.(0, size - 1);
        var indexesOdd = [0] ++ swapConsequtiveIndexes.(1, size - 1);
        var swappers = size.collect{ |n|
            {|toSwap| if(n.even)
                { indexesEven.collect{|i| toSwap[i]} }
                { indexesOdd.collect{|i|  toSwap[i]} }
            }
        };
        swappers.inject( [collection], {
            |col, f|
            col ++ [f.(col.last)]
        });
    }

    *ixi {|str|

        var stream = CollStream(str.stripWhiteSpace);
        var val, seq;
        var f1, f2;

        f2 = {|stream|
            var vals = List.new;
            var ch;
            while({ (ch = stream.next).notNil and: {ch != $]} }, {
                vals.add(ch.digit)
            });

            vals.asArray
        };

        f1 = {|stream|
            var vals = List.new;
            var ch;
            while({ (ch = stream.next).notNil and: {ch != $|} }, {

                switch(ch,
                    $[, {
                        var sub = f2.(stream);
                        vals.add(sub);
                    },
                    {
                        if (ch.isAlphaNum) {
                            vals.add(ch.digit)
                        } {
                            vals.add(\)
                        }
                    }
                );
            });

            vals.asArray
        };

        while({(val = stream.next).notNil}, {
            if (val == $|) {
                seq = f1.(stream);
            };
        });

        ^seq
    }
}
