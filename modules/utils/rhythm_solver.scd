


(
~combo = {arg target, divs, nums, pref;

	var returnVal, current;
	// no preference, equal weight
	var val = divs.choose;

	// prefer shorter values
	if (pref == \fast) {
		val = divs.sort.wchoose( (divs.size-1..0).normalizeSum );
	};

	// prefer longer values
	if (pref == \slow) {
		val = divs.sort.reverse.wchoose( (divs.size-1..0).normalizeSum );
	};

	if (val == target) {
		returnVal = [val];
	};

	current = sum(nums ++ [val]);
	if ( current == target ) {
		returnVal = nums ++ [val];
	} {
		if (current < target) {
			nums = nums ++ val;
		};
		returnVal = ~combo.(target, divs, nums)
	};
	returnVal;
};
)

[3,2,1].size

(3..0)

(
~rtn = Routine({

	var durs = ~combo.(8, [0.125,0.25,0.5,1,2], [], \fast).postln;
	var degrees = { (0..5).wchoose( (0..5).normalizeSum ) }.dup(durs.size);

	var durSeq = Pseq(durs, inf);
	var degreesSeq = Pseq(degrees, inf);

  	var result = Ptuple([durSeq, degreesSeq], inf).asStream;

	loop({
		result.next.yield;
	});
});

)

(
Pdef(\test, Pbind(
	\octave, Prand([5,6,7], inf),
	[\dur, \degree], ~rtn,
	\sustain, Pkey(\dur),
	\scale, Scale.minor,
));

)

(
~midi = SimpleMIDIFile( "~/projects/droptableuser/workspaces/ws12/pattern2.mid" );
~midi.init0(60, "4/4");
~midi.fromPattern(Pdef(\test));
~midi.write();
)

~midi.plot

Pdef(\test).play
"hello".postln


(

p = Pbind(

	\dur, Prand( [0.25,0.5,1], inf ),
	\freq, Pwhite( 440, 880 ),
	\db, Pwhite( -40,-10 ),
	\legato, Pwhite( 0.25, 4 ) );

m = SimpleMIDIFile( "~/Desktop/testPat.mid" );

m.init1( 2, 120, "4/4" );

m.fromPattern( p );

)



m.plot;



m.p.play; // note numbers are not rounded

p.play; // compare



m.write; // when writing to file note numbers are rounded (MIDI file format doesn't allow floats)

