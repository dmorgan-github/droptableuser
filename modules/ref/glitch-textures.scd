"http://sccode.org/1-5aw"


(
Ndef(\cicli){|speed=0.5|

	var size = 16;
	var nC = Dust.kr(0.05!size);
	var dC = Dust.kr(0.1!size);

	var localIn = LocalIn.kr(nC.size*2);
	var freq,sin;

	nC = nC + CoinGate.kr(TRand.kr(0.1,1,Dust.kr(0.1)),localIn[(0..nC.size-1)]).scramble;
	dC = dC + CoinGate.kr(TRand.kr(0.1,1,Dust.kr(0.1)),localIn[(nC.size..nC.size*2-1)]).scramble;

	freq = Demand.kr(nC,80,Drand(80*((Scale.major.ratios*.1(2**(0..4))).flat),inf));
	sin = SinOsc.ar(freq)*EnvGen.kr(Env.perc(0.1,2),Impulse.kr(TRand.kr(0.2,1.2,dC)*speed));
	LocalOut.kr(nC++dC);
	Mix(Pan2.ar(sin/sin.size*AmpCompA.kr(freq),[-1,1]))*4

}.fadeTime_(0).playN([0,1]);
)
Ndef(\cicli).stop;

5*.1(3)

(
Ndef(\cicliCtrl2){|slow=1,n_slow=1,glitch=1|
	var size = 16;
	var localIn = LocalIn.kr(size*2);

	var m = Dust.kr((0.05*n_slow)!size);
	var r = Dust.kr(0.1!size);
	var c;
	var l;

	m = m + CoinGate.kr(TRand.kr(glitch,1,m),localIn[(0..size-1)]).scramble;
	r = r + CoinGate.kr(TRand.kr(glitch,1,r),localIn[(size..size*2-1)]).scramble;

	c = Demand.kr(m,80,Drand(80*((Scale.major.ratios*.1(2**(0..4))).flat),inf));
	l = SinOsc.ar(c)*EnvGen.kr(Env.perc(0.1,2),Impulse.kr(TRand.kr(0.2,1.2,r)*slow));

	LocalOut.kr(m++r);

	Mix(Pan2.ar(l/l.size*AmpCompA.kr(c),[-1,1]))*4 * 0.2

}.fadeTime_(0).playN([0,1]);
)

Ndef(\cicliCtrl2).stop;

(
Ndef(\cicliSimpler){
	var m = rrand(2,16);
	var r = exprand(0.01,10);
	var c = exprand(0.01,2);
	var l = rrand(3,8);

	var scale = (80*Scale.major.ratios*.1(2**(0..(l-1)))).flat.sort.as(LocalBuf);
	var trig = Dust.kr([(r)!m,Dust.kr(c!m)]);
	var freq = Index.kr(scale,IndexInBetween.kr(scale,TRand.kr(80,80*(2**l),trig[0])));

	Mix(Pan2.ar(
		SinOsc.ar(freq)*EnvGen.kr(Env.perc(0.1,2),Impulse.kr(TRand.kr(0.2,1.2,trig[1])))
		/m*AmpCompA.kr(freq),
		[-1,1])) * 0.5;

}.fadeTime_(0.1).playN([0,1]);
)

(80*Scale.major.ratios * .1(2**(0..(rrand(3,8)-1)))).flat.sort