(
play {
var impulse = Decay.ar(Impulse.ar(0.5),0.1);
impulse = BPF.ar(impulse*MouseY.kr(1,100), 50).sin;
Pluck.ar(impulse, LFSaw.ar(10000), 0.1, 1/MouseX.kr(50,400,\exponential),4)  ! 2;
};
)