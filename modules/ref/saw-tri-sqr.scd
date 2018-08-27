(
/* Each octave requires a separate buffer. Each buffer has fewer harmonics so we avoid problems with nyquist.

This function takes a base frequency (which will be the lowest note on the piano in this
code because I'm a traditionalist) and uses that to identify the first buffer, and then
keeps creating buffers until it reaches the last octave than we can implement for the
current sample rate.

This isn't super efficient, but it suffices and nothing is hard-coded.
*/
var makeBuf = {|baseFreq, fn|   // fn is the function that defines the harmonics for each buffer
  var maxFreq = Server.local.sampleRate;
  var freqs = Array.series(20, baseFreq, 12).midicps.select({|item| item < maxFreq});
  var bufCount = freqs.size;
  // Need consecutive buffers if we're going to use vosc
  Buffer.allocConsecutive(bufCount, s, 4096, 1, {|buf, i|
    var harms = maxFreq.div(freqs[i]);
    fn.(buf, harms);
  });
};

/* This function takes the baseFreq that we defined when creating our buffers, the base
buffer and the number of buffers that were created.

It uses these to create a new function which takes frequency and phase and returns a VOsc
that knows about our buffers. This function can then be used in SynthDefs similarly to how
we might use UGens. We will use it below to create square waves, triangle, etc.
*/
var makeOsc = {|baseFreq, baseBuf, bufCount|
  {|freq, phase|
    var bufPos = ((freq-baseFreq).cpsmidi / 12).clip(0, bufCount) + baseBuf-1;
    VOsc.ar(bufPos, freq, phase);
  }
};

var baseFreq = 21;

/* All the creation of buffers, harmonics, etc happens inside a function, that we then
call. This ensures that our buffers are only accessible by our new Saw Wave pseudo ugen */
var wavSaw = {
  var makeSaw = {|buf, harms|
    buf.sine3Msg((1..harms),  // This defines the harmonics for our saw wave.
      (1..harms).reciprocal,  // This defines the amplitudes for our saw wave.
      (1..harms).collect({|x| if(x.odd){0}{pi}})); // This defines the phases
  };

  var bufs = makeBuf.(baseFreq, makeSaw);  // make the buffers using our makeSaw function
  makeOsc.(baseFreq, bufs[0].bufnum, bufs.size); // create an oscillator function.
}.();

var wavTri = {
  var makeTri = {|buf, harms|
    buf.sine3Msg((1..harms).select(_.odd),
      (1..harms).select(_.odd).collect(_.squared.reciprocal),
      (1..harms).select(_.odd).collect({|x| if(x.odd){0}{pi}}));
  };

  var bufs = makeBuf.(baseFreq, makeTri);
  makeOsc.(baseFreq, bufs[0].bufnum, bufs.size);
}.();

var wavSqr = {
  var makeSqr = {|buf, harms, duty|
  buf.sine2Msg((1..harms).select(_.odd),
    (1..harms).select(_.odd).collect(_.reciprocal))
  };

  var bufs = makeBuf.(baseFreq, makeSqr);
  makeOsc.(baseFreq, bufs[0].bufnum, bufs.size);
}.();

SynthDef(\WavSaw, {
  Out.ar(0, wavSaw.(\freq.kr(220), \phase.kr(pi))); // we call wavSaw and this handles creating the ugen graph thingy ma job.
}).add;

SynthDef(\WavTri, {
  Out.ar(0, wavTri.(\freq.kr(220), \phase.kr(pi)));
}).add;

SynthDef(\WavSqr, {
  Out.ar(0, wavTri.(\freq.kr(220), \phase.kr(pi)));
}).add;

)

Synth(\WavSaw)
Synth(\WavTri)
Synth(\WavSqr)