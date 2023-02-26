(
synth: {|gate, doneAction=(Done.freeSelf)|
    //var env = Env([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4] ).ar(gate:gate, doneAction:Done.freeSelf);
    var env = Env([0, 1, 0.5, 0], [0.002, 0.06, 0.26], [-4, -2, -4] ).ar(gate:gate, doneAction:Done.freeSelf);
    env;
},
props: (
    hasgate: false
)
)

