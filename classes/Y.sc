//http://sccode.org/1-57L
Y {

    //------------------------------------------------------------------------
    // comp
    // generates all compositions of n
    //------------------------------------------------------------------------
    /*
    Y.comp(4).do{|x| x.postln};
    Y.comp(5).do{|x| x.postln};
    Y.comp(6).do{|x| x.postln};
    Y.comp(7).do{|x| x.postln};
    */
    *comp {|n|
        var res = List.new;
        var parts = Array.newClear(n-1);
        var compose = {|n, p, m|
            if(n == 0, {
                res.add(parts.copyRange(0, m-1) ++ p);
            }, {
                parts[m] = p;
                compose.(n-1, 1, m+1);
                compose.(n-1, p+1, m);
            });
        };
        compose.(n-1, 1, 0);
        ^res;
    }

    //------------------------------------------------------------------------
    // compm
    // generates all compositions of n into m parts
    //------------------------------------------------------------------------
    /*
    Y.compm(4, 3).do{|x| x.postln};
    Y.compm(5, 3).do{|x| x.postln};
    Y.compm(6, 3).do{|x| x.postln};
    Y.compm(7, 3).do{|x| x.postln};
    */

    *compm {|n, m|
        var res= List.new;
        var parts= Array.newClear(n-1);
        var mp= m-1;
        var compose= {|n, p, m|
            if(n==0, {
                if(m==mp, {
                    res.add(parts.copyRange(0, m-1)++p);
                });
            }, {
                if(m<mp, {
                    parts[m]= p;
                    compose.(n-1, 1, m+1);
                });
                compose.(n-1, p+1, m);
            });
        };
        compose.(n-1, 1, 0);
        ^res;
    }

    //------------------------------------------------------------------------
    // compa
    // generates compositions of n with allowed parts pi
    //------------------------------------------------------------------------
    /*
    Y.compa(8, 3, 4, 5, 6).do{|x| x.postln};
    Y.compa(8, 2, 4, 5, 6).do{|x| x.postln};
    Y.compa(8, 1, 4, 5, 6).do{|x| x.postln};
    */
    *compa {|n ...p|
        var res= List.new;
        var parts= Array.newClear(n-1);
        var aparts= p;
        var allowed= {|p| aparts.includes(p)};
        var compose= {|n, p, m|
            if(n==0, {
                if(allowed.(p), {
                    res.add(parts.copyRange(0, m-1)++p);
                });
            }, {
                if(allowed.(p), {
                    parts[m]= p;
                    compose.(n-1, 1, m+1);
                });
                compose.(n-1, p+1, m);
            });
        };
        compose.(n-1, 1, 0);
        ^res;
    }


    //------------------------------------------------------------------------
    // compam
    // generates compositions of n with m parts from the set (p1 p2 ...)
    //------------------------------------------------------------------------
    /*
    Y.compam(16, 5, 2, 3, 4).do{|x| x.postln};
    Y.compam(16, 5, 1, 2, 3, 4).do{|x| x.postln};
    Y.compam(16, 5, 1, 2, 3, 4, 5).do{|x| x.postln};
    */
    *compam {|n, m ...p|
        var res= List.new;
        var parts= Array.newClear(n-1);
        var mp= m-1;
        var aparts= p;
        var allowed= {|p| aparts.includes(p)};
        var compose= {|n, p, m|
            if(n==0, {
                if(m==mp and:{allowed.(p)}, {
                    res.add(parts.copyRange(0, m-1)++p);
                });
            }, {
                if(m<mp and:{allowed.(p)}, {
                    parts[m]= p;
                    compose.(n-1, 1, m+1);
                });
                compose.(n-1, p+1, m);
            });
        };
        compose.(n-1, 1, 0);
        ^res;
    }

    //------------------------------------------------------------------------
    // comprnd
    // generate random composition of n
    //------------------------------------------------------------------------
    /*
    Y.comprnd(3).do{|x| x.postln};
    Y.comprnd(4).do{|x| x.postln};
    Y.comprnd(8).do{|x| x.postln};
    */
    *comprnd {|n|
        var res= List.new;
        var p= 1;
        (n-1).do{
            if(0.5.coin, {
                p= p+1;
            }, {
                res.add(p);
                p= 1;
            });
        };
        res.add(p);
        ^res;
    }


    //------------------------------------------------------------------------
    // compmrnd
    // generate random composition of n into m parts
    //------------------------------------------------------------------------
    /*
    Y.compmrnd(3, 2).do{|x| x.postln};
    Y.compmrnd(4, 2).do{|x| x.postln};
    Y.compmrnd(8, 2).do{|x| x.postln};
    Y.compmrnd(8, 4).do{|x| x.postln};
    */
    *compmrnd {|n, m|
        var res= List.new;
        var mp= m-1;
        var np= n-1;
        var p;
        var j= 1;
        while({mp>0}, {
            p= mp*(1/np);
            if(1.0.rand<p, {
                res.add(j);
                mp= mp-1;
                j= 1;
            }, {
                j= j+1;
            });
            np= np-1;
        });
        res.add(j+np);
        ^res;
    }



    //------------------------------------------------------------------------
    // neck
    // generates all binary necklaces of length n
    //------------------------------------------------------------------------
    /*
    Y.neck(4).do{|x| x.postln};
    Y.neck(5).do{|x| x.postln};
    Y.neck(6).do{|x| x.postln};
    */
    *neck {|n|
        var res= List.new;
        var b= Array.newClear(n+1);
        var neckbin= {|k, l|
            if(k>n, {
                if((n%l)==0, {
                    res.add(b.copyRange(1, n));
                });
            }, {
                b[k]= b[k-l];
                if(b[k]==1, {
                    neckbin.(k+1, l);
                    b[k]= 0;
                    neckbin.(k+1, k);
                }, {
                    neckbin.(k+1, l);
                });
            });
        };
        b[0]= 1;
        neckbin.(1, 1);
        ^res;
    }


    //------------------------------------------------------------------------
    // neckm
    // generates all binary necklaces of length n with m ones
    //------------------------------------------------------------------------
    /*
    Y.neckm(4, 2).do{|x| x.postln};
    Y.neckm(8, 2).do{|x| x.postln};
    Y.neckm(8, 4).do{|x| x.postln};
    */
    *neckm {|n, n1|
        var res= List.new;
        var b= Array.newClear(n+1);
        var neckbin= {|k, l, m|
            if(k>n, {
                if((n%l)==0 and:{m==n1}, {
                    res.add(b.copyRange(1, n));
                });
            }, {
                b[k]= b[k-l];
                if(b[k]==1, {
                    neckbin.(k+1, l, m+1);
                    b[k]= 0;
                    neckbin.(k+1, k, m);
                }, {
                    neckbin.(k+1, l, m);
                });
            });
        };
        b[0]= 1;
        neckbin.(1, 1, 0);
        ^res;
    }



    //------------------------------------------------------------------------
    // necka
    // generates binary necklaces of length n with allowed parts pi
    //------------------------------------------------------------------------
    /*
    Y.necka(4, 2, 3, 4).do{|x| x.postln};
    Y.necka(8, 2, 3, 4).do{|x| x.postln};
    Y.necka(8, 4, 1).do{|x| x.postln};
    */
    *necka {|n ...p|
        var res= List.new;
        var b= Array.newClear(n+1);
        var aparts= p;
        var allowed= {|p| aparts.includes(p)};
        var neckbin= {|k, l, p|
            if(k>n, {
                if((n%l)==0 and:{allowed.(p) and:{p<=n}}, {
                    res.add(b.copyRange(1, n));
                });
            }, {
                b[k]= b[k-l];
                if(b[k]==1, {
                    if(allowed.(p) or:{k==1}, {neckbin.(k+1, l, 1)});
                    b[k]= 0;
                    neckbin.(k+1, k, p+1);
                }, {
                    neckbin.(k+1, l, p+1);
                });
            });
        };
        b[0]= 1;
        neckbin.(1, 1, 1);
        ^res;
    }


    //------------------------------------------------------------------------
    // neckam
    // generates binary necklaces of length n with m ones and allowed parts pi
    //------------------------------------------------------------------------
    /*
    Y.neckam(8, 4, 1, 3).do{|x| x.postln};
    Y.neckam(16, 5, 2, 3, 4).do{|x| x.postln};
    */
    *neckam {|n, n1 ...p|
        var res= List.new;
        var b= Array.newClear(n+1);
        var aparts= p;
        var allowed= {|p| aparts.includes(p)};
        var neckbin= {|k, l, m, p|
            if(k>n, {
                if((n%l)==0 and:{allowed.(p) and:{p<=n and:{m==n1}}}, {
                    res.add(b.copyRange(1, n));
                });
            }, {
                b[k]= b[k-l];
                if(b[k]==1, {
                    if(allowed.(p) or:{k==1}, {neckbin.(k+1, l, m+1, 1)});
                    b[k]= 0;
                    neckbin.(k+1, k, m, p+1);
                }, {
                    neckbin.(k+1, l, m, p+1);
                });
            });
        };
        b[0]= 1;
        neckbin.(1, 1, 0, 1);
        ^res;
    }

    //------------------------------------------------------------------------
    // part
    // generates all partitions of n
    //------------------------------------------------------------------------
    /*
    Y.part(4).do{|x| x.postln};
    Y.part(5).do{|x| x.postln};
    Y.part(6).do{|x| x.postln};
    */
    *part {|n|
        var res= List.new;
        var parts= Array.newClear(n-1);
        var partitions= {|n, p, m|
            if(n==0, {
                res.add(parts.copyRange(0, m-1)++p);
            }, {
                if(n>0, {
                    parts[m]= p;
                    partitions.(n-p, p, m+1);
                    partitions.(n-1, p+1, m);
                });
            });
        };
        partitions.(n-1, 1, 0);
        ^res;
    }

    //------------------------------------------------------------------------
    // partm
    // generates all partitions of n into m parts
    //------------------------------------------------------------------------
    /*
    Y.partm(4, 3).do{|x| x.postln};
    Y.partm(4, 2).do{|x| x.postln};
    */
    *partm {|n, m|
        var res= List.new;
        var parts= Array.newClear(n-1);
        var mp= m-1;
        var partitions= {|n, p, m|
            if(n==0, {
                if(m==mp, {
                    res.add(parts.copyRange(0, m-1)++p);
                });
            }, {
                if(n>0, {
                    if(m<mp, {
                        parts[m]= p;
                        partitions.(n-p, p, m+1);
                    });
                    partitions.(n-1, p+1, m);
                });
            });
        };
        partitions.(n-1, 1, 0);
        ^res;
    }


    //------------------------------------------------------------------------
    // parta
    // generates all partitions of n with allowed parts pi
    //------------------------------------------------------------------------
    /*
    Y.parta(8, 2, 3).do{|x| x.postln};
    Y.parta(8, 1, 4).do{|x| x.postln};
    */
    *parta {|n ...p|
        var res= List.new;
        var parts= Array.newClear(n-1);
        var aparts= p;
        var allowed= {|p| aparts.includes(p)};
        var partitions= {|n, p, m|
            if(n==0, {
                if(allowed.(p), {
                    res.add(parts.copyRange(0, m-1)++p);
                });
            }, {
                if(n>0, {
                    if(allowed.(p), {
                        parts[m]= p;
                        partitions.(n-p, p, m+1);
                    });
                    partitions.(n-1, p+1, m);
                });
            });
        };
        partitions.(n-1, 1, 0);
        ^res;
    }


    //------------------------------------------------------------------------
    // partam
    // generates all partitions of n with m parts from the set (p1 p2 ...)
    //------------------------------------------------------------------------
    /*
    Y.partam(16, 5, 1, 2, 3, 4, 5).do{|x| x.postln};
    */
    *partam {|n, m ...p|
        var res= List.new;
        var parts= Array.newClear(n-1);
        var mp= m-1;
        var aparts= p;
        var allowed= {|p| aparts.includes(p)};
        var partitions= {|n, p, m|
            if(n==0, {
                if(m==mp and:{allowed.(p)}, {
                    res.add(parts.copyRange(0, m-1)++p);
                });
            }, {
                if(n>0, {
                    if(m<mp and:{allowed.(p)}, {
                        parts[m]= p;
                        partitions.(n-p, p, m+1);
                    });
                    partitions.(n-1, p+1, m);
                });
            });
        };
        partitions.(n-1, 1, 0);
        ^res;
    }

    //------------------------------------------------------------------------
    // permi
    // generates permutations of the integers ai>=0
    // to generate all permutations they must be ordered a1<a2<...<an
    // any other order will only generate permutations that are larger
    // in lexicographic order
    //------------------------------------------------------------------------
    /*
    Y.permi(1, 2, 3).do{|x| x.postln};
    Y.permi(0, 1, 2).do{|x| x.postln};
    */
    *permi {|...a|
        var res= List.new;
        var n= a.size, i, j, m, k;
        var running= true;
        a= [-1]++a;
        while({running}, {
            res.add(a.copyRange(1, n));
            i= n-1;
            while({i>0 and:{a[i]>=a[i+1]}}, {
                i= i-1;
            });
            if(i==0, {
                running= false;
            }, {
                j= n;
                while({a[i]>=a[j]}, {
                    j= j-1;
                });
                m= a[j];
                a[j]= a[i];
                a[i]= m;
                j= i+1;
                k= n;
                while({j<k}, {
                    m= a[j];
                    a[j]= a[k];
                    a[k]= m;
                    j= j+1;
                    k= k-1;
                });
            });
        });
        ^res;
    }

    //------------------------------------------------------------------------
    // debruijn
    // generates the largest de Bruijn sequence of order n
    //------------------------------------------------------------------------
    /*
    Y.debruijn(3).do{|x| x.postln};
    Y.debruijn(4).do{|x| x.postln};
    */
    *debruijn {|n|
        var ndbs= 1<<n;
        var idbs= 0;
        var dbs;
        var b= Array.newClear(n+1);
        var neckbin= {|k, l|
            if(k>n, {
                if((n%l)==0, {
                    l.do{|k|
                        dbs[idbs+k]= if(b[k+1]==0, {0}, {1});
                    };
                    idbs= idbs+l;
                });
            }, {
                b[k]= b[k-l];
                if(b[k]==1, {
                    neckbin.(k+1, l);
                    b[k]= 0;
                    neckbin.(k+1, k);
                }, {
                    neckbin.(k+1, l);
                });
            });
        };
        b[0]= 1;
        dbs= Array.newClear(ndbs);
        neckbin.(1, 1);
        ^dbs;
    }

    //------------------------------------------------------------------------
    // b2int
    // reads binary strings and converts them to interval notation
    //------------------------------------------------------------------------
    /*
    Y.b2int("1010010001001000");
    */
    *b2int {|line|
        var res= List.new;
        var nbit= line.size;
        var k, j= 0;
        while({j<nbit}, {
            k= 1;
            while({line[j= j+1]!=$1 and:{j<nbit}}, {
                k= k+1;
            });
            res.add(k);
        });
        ^res;
    }


    //------------------------------------------------------------------------
    // int2b
    // reads intervals and converts them to a binary string
    //------------------------------------------------------------------------
    /*
    Y.int2b([2, 3, 4, 3, 4]);
    */
    *int2b {|line|
        var res= "";
        line.do{|k|
            res= res++$1;
            (k-1).do{res= res++$0};
        };
        ^res;
    }


    //------------------------------------------------------------------------
    // chsequl
    // generates the upper or lower Christoffel word for p/q
    //   t= type of word (\upper or \lower)
    //   p= numerator
    //   q= denominator
    //   n= number of terms to generate, default= p+q
    //------------------------------------------------------------------------
    /*
    Y.chsequl(\upper, 8, 7, 6).do{|x| x.postln};
    Y.chsequl(\upper, 8, 7, 5).do{|x| x.postln};
    Y.chsequl(\upper, 8, 3).do{|x| x.postln};
    Y.chsequl(\lower, 8, 3).do{|x| x.postln};
    Y.chsequl(\lower, 3, 8).do{|x| x.postln};
    Y.chsequl(\upper, 3, 8).do{|x| x.postln};
    */
    *chsequl {|t, p, q, n|
        var res= List.new;
        var i= 0, a, b;
        n= n??{p+q};
        while({
            res.add(if(t==\upper, 1, 0));
            i= i+1;
            a= p;
            b= q;
            while({a!=b and:{i<n}}, {
                if(a>b, {
                    res.add(1);
                    b= b+q;
                }, {
                    res.add(0);
                    a= a+p;
                });
                if(a==b and:{i<n}, {
                    res.add(if(t==\upper, 0, 1));
                    i= i+1;
                });
                i= i+1;
            });
            i<n;
        }, {});
        ^res;
    }


    //------------------------------------------------------------------------
    // cfsqrt
    // calculates continued fractions for: sqrt(n)
    //------------------------------------------------------------------------
    /*
    Y.cfsqrt(3);
    Y.cfsqrt(12);
    Y.cfsqrt(32);
    Y.cfsqrt(128);
    */
    *cfsqrt {|n|
        var res= List.new;
        var frac= List.new;
        var aa= 0, bb= 1, a0= sqrt(n).asInteger;
        var a= a0;
        res.add(a);
        if(a*a<n, {
            while({a!=(2*a0)}, {
                aa= bb*a-aa;
                bb= (n-(aa*aa)).div(bb);
                a= (a0+aa).div(bb);
                frac.add(a);
            });
        });
        ^res.add(frac);
    }

    //------------------------------------------------------------------------
    // cfcv
    // calculates a continued fraction convergent
    //------------------------------------------------------------------------
    /*
    Y.cfcv(1, 1, 2);
    Y.cfcv(1, 1, 2, 1, 2);
    Y.cfcv(1, 2, 3, 4);
    Y.cfcv(1, 2, 3, 4, 5);
    */
    *cfcv {|...ai|
        var res= List.new;
        var p0= 0, p1= 1, q0= 1, q1= 0;
        var p2, q2;
        ai.do{|a|
            p2= a*p1+p0;
            q2= a*q1+q0;
            p0= p1;
            p1= p2;
            q0= q1;
            q1= q2;
        };
        ^res.add(p2).add(q2);
    }


    //------------------------------------------------------------------------
    // pfold
    // generates fold sequences
    //   n= number of terms, 1,3,7,15,31,63,127,...
    //   m= number of bits
    //   f= function number 0 -> 2^m-1
    //------------------------------------------------------------------------
    /*
    Y.pfold(15, 4, 1);
    Y.pfold(31, 5, 0);
    Y.pfold(3, 4, 5);
    Y.pfold(4, 5, 6);
    */
    *pfold {|n, m, f|
        var res= List.new;
        var i= 1, j, k, b;
        var oddeven= {|n, a, b|  //finds a and b such that n= 2^a*(2*b+1)
            var k= 0, l;
            l= n&(0-n);
            b= (n/l-1).div(2);
            while({l>1}, {
                l= l>>1;
                k= k+1;
            });
            [k, b];
        };
        while({i<=n}, {
            #k, j= oddeven.(i, k, j);
            k= k%m;
            b= if(f&(1<<k)>0, 1, 0);
            if((2*j+1)%4>1, {b= 1-b});
            res.add(b);
            i= i+1;
        });
        ^res;
    }

    //------------------------------------------------------------------------
    // rndint
    // generates random numbers with specified correlation
    //   m= range of numbers, 0 to m
    //   s= starting number, 0 to m
    //   c= degree of correlation
    //      0= total correlation (all numbers= s)
    //      m= no correlation (each number is independent)
    //   n= how many random numbers to generate
    //------------------------------------------------------------------------
    /*
    Y.rndint(3, 2, 1, 4);
    Y.rndint(5, 2, 2, 8);
    */
    *rndint {|m, s, c, n|
        var res= List.new;
        var i= 0, j, k;
        while({i<n}, {
            res.add(s);
            if(c>0, {
                j= m;
                while({j>(m-c)}, {
                    k= 1/j;
                    if(1.0.rand<(s*k), {s= s-1});
                    j= j-1;
                });
                k= 1/2;
                j= 0;
                while({j<c}, {
                    if(1.0.rand<k, {s= s+1});
                    j= j+1;
                });
            });
            i= i+1;
        });
        ^res;
    }

    //------------------------------------------------------------------------
    // markovgen
    // generates random numbers using a markov chain
    //   mfile= transition matrix file name
    //   s= starting state
    //   n= how many random numbers to generate
    //------------------------------------------------------------------------

    /*
    ~table = #[4,
      0, 1, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1,
      1, 0, 0, 0
    ];
    Y.markovgen(~table, 0, 8);
    Y.markovgen(~table, 1, 8);
    Y.markovgen([2, 0.75, 0.25, 0.25, 0.75], 0, 8);
    */
    *markovgen {|m, s, n|
        var res= List.new;
        var ns= m[0];  //number of states
        var pM, mm, u, j, x;
        n.do{|i|
            res.add(s);
            pM= m.drop(1).clump(ns)[s];
            u= 1.0.rand;
            j= 0;
            x= 0.0;
            while({j<ns}, {
                x= x+pM[j];
                if(u<x, {s= j; j= ns});
                j= j+1;
            });
        };
        ^res;
    }

    /*
    https://scsynth.org/t/rhythmic-algorithms/3648/5
    Y.polybjorklund([3, 2, 2], 24, [4, 0, 3]).asStream.nextN(25);
    */
    *polybjorklund {|k = 4, n = 12, offset = 0, weight = 1|
        // k: number of "hits" per phrase (use an array for polyrhythms, integer for monorhythm)
        // n: number of beats in a phrase (use an array for polymeters, integer for monometer)
        // offset: rotate the rhythms by some integer (use an array to get different offsets for each sub-rhythm)
        // weight: an array of 1s and -1s (e.g. [1, 1, -1]), a way of adding or subtracting each sub-rhythm from the final result.
        var results = ();
        var output = 0;
        k = k.asArray; n = n.asArray; offset = offset.asArray; weight = weight.asArray;
        weight.asSet.do{|w| results[w] = 0};
        maxItem([k.size, n.size, offset.size, weight.size]).collect({|i|
            var thisPolygon = Pbjorklund(k.wrapAt(i), n.wrapAt(i), inf, offset.wrapAt(i));
            results[weight.wrapAt(i)] = (results[weight.wrapAt(i)] + thisPolygon).clip(0, 1);
        });
        results.keysValuesDo({|weight, pattern|
            output = output + (pattern * weight);
        });
        ^output.clip(0, 1);
    }

    *vowelmap {|str|
        ^str
        .stripWhiteSpace
        .replace($\ , "")
        .toLower
        .ascii
        .reject({|val| (val < 97 or: {val > 122} ) })
        .collect({|val|
            switch(val)
            {97} {1}  // a
            {101} {1} // e
            {105} {1} // i
            {111} {1} // o
            {117} {1} // u
            {0};
        })
    }

    *binary {|int, numDigits=8|
        ^int.asBinaryDigits(numDigits)
    }

    // this will clip the last value to make it fit to target
    /*
    Y.anyupto(16, [3, 5, 1, 2])
    */
    *anyupto {|target, divs|

        var func = {|target, divs, nums = ([])|

            var returnVal, current;
            // no preference, equal weight
            var val = divs.choose;

            if (val == target) {
                returnVal = [val];
            };

            current = sum(nums ++ [val]);
            if ( current == target ) {
                returnVal = nums ++ [val];
            } {
                if (current < target) {
                    nums = nums ++ val;
                    returnVal = func.value(target, divs, nums);
                } {
                    val = target - sum(nums);
                    returnVal = nums ++ [val];
                }
            };

            returnVal;
        };

        ^func.(target, divs);
    }
}

C {

    *henon {|a = 1.4, b = 0.3, x0 = 0, x1 = 1, size = 64|
        ^size.collect({ var aux = 1 - (a * (x1 ** 2)) + (b * x0); x0 = x1; x1 = aux; aux });
    }

    *quad {|a = 1, b = -1, c = -0.75, xi = 0, size = 64|
        ^size.collect({ xi = (a * (xi ** 2)) + (b * xi) + c; xi })
    }

    *cusp {|a = 1.0, b = 1.9, xi = 0, size = 64|
        ^size.collect({ xi = a - (b * sqrt(abs(xi))) })
    }

    *gbman {|xi = 1.2, yi = 2.1, size = 64|
        size.collect({ var x; xi = 1 - yi + abs(x = xi); yi = x; xi })
    }

    *latoocarfian {|a = 1, b = 3, c = 0.5, d = 0.5, xi = 0.5, yi = 0.5, size = 64|
        ^size.collect({ var x = xi;
            xi = sin(b * yi) + (c * sin(b * xi));
            yi = sin(a * x) + (d * sin(a * yi));
            xi
        })
    }

    *lincong {|a = 1.1, c = 0.13, m = 1, xi = 0, size = 64|
        ^size.collect({ xi = (a * xi + c) % m })
    }

    *standard {|k = 1, xi = 0.5, yi = 0, size = 64|
        ^size.collect({ yi = yi + (k * sin(xi)) % 2pi; xi = (xi + yi) % 2pi; xi - pi * 0.3183098861837907 })
    }

    *fbsine {|im = 1, fb = 0.1, a = 1.1, c = 0.5, xi = 0.1, yi = 0.1, size = 64|
        ^size.collect({ xi = sin((im * yi) + (fb * xi)); yi = (a * yi + c) % 2pi; xi })
    }
}