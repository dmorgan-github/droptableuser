var fromControl = {|controls|
    controls.clump(3).collect({arg item;
        [(item[0] + 1000.cpsmidi).midicps, item[1], 10**item[2]]
    });
};

(
synth: {|in|
    var frdb, input = in;
    frdb = fromControl.(Control.names([\eq_controls]).kr(0!15));
    input = BLowShelf.ar(input, *frdb[0][[0,2,1]].lag(0.1));
    input = BPeakEQ.ar(input, *frdb[1][[0,2,1]].lag(0.1));
    input = BPeakEQ.ar(input, *frdb[2][[0,2,1]].lag(0.1));
    input = BPeakEQ.ar(input, *frdb[3][[0,2,1]].lag(0.1));
    input = BHiShelf.ar(input, *frdb[4][[0,2,1]].lag(0.1));
    input = RemoveBadValues.ar(input);
    input;
},
view: 'beq'
)

