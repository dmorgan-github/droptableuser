(
/*
Shift register code adapted from here:
"http://new-supercollider-mailing-lists-forums-use-these.2681727.n2.nabble.com/serial-in-parallell-out-shift-register-ugen-td6331387.html"
*/
~shift_register = {arg chans = 1, length = 5;

	{
		var in = \in.kr(0);
		var trig = \trig.kr(0.dup(chans));
		var buf = LocalBuf(length);
		var count = PulseCount.kr(trig);

		Demand.kr(trig, 0, Dbufwr(in, buf, count));
		Demand.kr(trig, 0, Dbufrd(buf, count + (1..length))).reverse;
	}
};
Library.put(\modules, \logic, \shift_register, ~shift_register);
)
