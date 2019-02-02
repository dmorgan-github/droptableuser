(
{
    var drop, outof;
    var in, zerocross, count, out;
    drop = 10;
    outof = 20;
    in = SinOsc.ar(440);
    zerocross = ((Delay1.ar(in) < 0) & (in >= 0));
    count = Stepper.ar(zerocross, 0, 0, outof, 1);
    out = (count >= drop) * in;
    [out, WaveLoss.ar(in, drop, outof, 1)];
}.plot(0.3);
)

(
{
    var drop, outof;
    var in, zerocross, count, out;
    drop = 10;
    outof = 20;
    in = SinOsc.ar(440);
    zerocross = ((Delay1.ar(in) < 0) & (in >= 0));
    out = (TRand.ar(0, 1, zerocross) > (drop / outof)) * in;
    [out, WaveLoss.ar(in, drop, outof, 2)];
}.plot(0.3);
)