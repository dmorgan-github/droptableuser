~sc = ProxySpace.new(s);

~sc[\pads] = { Splay.ar(Saw.ar([60, 62, 65, 67].midicps/2)) * 0.5 }; // shitty pads
~sc[\kick] = { Decay2.ar(Impulse.ar(2), 0.01, 1) * SinOsc.ar(80).dup }; // shitty kicks

~sc[\master].play; // node proxy for everything (as a master effect)
(
~sc[\master] = {
	// same arguments as the other example:
	var thresh = 0.1;
	var compression = 0.1;
	var attack = 0.01;
	var release = 0.1;
	// here you get the signals directly from the node proxies, not over audio channels... easier to read
	var snd = Compander.ar(~sc[\pads].ar, ~sc[\kick].ar, thresh, 1, compression, attack, release);
	snd + ~sc[\kick].ar
	// the proxy has it's own output. Alternatively you can ~kick.play to hear the kick directly, you won't have to add it here
}
)
~sc[\kick].play