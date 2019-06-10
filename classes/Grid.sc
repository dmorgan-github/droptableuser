G {
	var <key;

	*new { arg key, defs, div;
		^super.new.gridInit(key, defs, div);
	}

	gridInit {arg inKey, inDefs, div;
		key = inKey.asSymbol;
		if (inDefs.isNil.not) {
			this.prBuild(inDefs, div);
		};
		^Pdef(key);
	}

	prBuild {arg inDefs, div=(1/16);

		Pdef(this.key, {

			Pspawner({arg ps;
				var prevbeat = -1;
				var prevbar = -1;
				var funcs = inDefs.collect({arg func; func.value;});
				inf.do({arg i;
					var tempo = thisThread.clock;
					Environment.make({
						~midiout = MIDIOut(0);
						~frame = i;
						~bar = tempo.bar.asInt;
						~beat = tempo.beatInBar;
						~beatInt = tempo.beatInBar.floor.asInt;
						~beatdur = tempo.beatDur;
						~div = div;
						~beatchanged = false;
						if (prevbeat != ~beatInt) {
							prevbeat = ~beatInt;
							~beatchanged = true;
						};
						~barchanged = false;
						if (prevbar != ~bar) {
							prevbar = ~bar;
							~barchanged = true;
						};
						funcs.do({arg func;
							var val = func.next.valueEnvir;
							if (val.class == Event){
								ps.par(Pn(val.valueEnvir,1))
							}
						});
					});
					ps.wait(div.next);
				});
			})
		});
	}

	*every {arg num, div, func;
		if (num.mod(div) == 0) {
			^func.();
		}{
			^nil;
		}
	}

	*parse {arg str;
		^str.digit.collect({arg val; if (val.isNil){Rest()}{val}});
	}
}