
MIDIClient.init;
MIDIClient.initialized
MIDIIn.connectAll;

MIDIIn.disconnectAll;
MIDIClient.sources[1].uid
MIDIdef.freeAll;




(
MIDIdef.polytouch(\poly, {arg val, vel;
	//[\poly, val, vel].postln;
});
MIDIdef.touch(\touch, {arg val, vel;
	//[\touch, val, vel].postln;
})
)

(
MIDIdef.cc(\cc, {arg a, b, c, d;
	[\cc, a, b, c, d].postln;
});
)

(
MIDIdef.bend(\bend, {arg val, vel;
	var st = val.linlin(6290, 10099, -24, 24);
	[\bend, st.midiratio, val, vel].postln;
})
)

(
/*
48 to 72
*/
MIDIdef.noteOn(\noteOn, {arg ...args;
	var note = args[1];
	var vel = args[0];
	var chan = args[2];
	var key = ('noteOn' ++ chan).asSymbol;
	[note, vel, chan, key].postln;
	//Fdef(key).value(note, vel);
});
MIDIdef.noteOff(\noteOff, {arg ...args;
	var note = args[1];
	var vel = args[0];
	var chan = args[2];
	var key = ('noteOff' ++ chan).asSymbol;
	[note, vel, chan, key].postln;
});
)

(
var view = View();
view.front;
)


(
// create the TabbedView2
var tabView = TabbedView2();

//add defaults, before creating tabs
//t.backgrounds_([Color(0.9,0.85,0.85),Color(0.85,0.85,0.9),Color(0.9,0.9,0.85)]);
//t.unfocusedColors_([Color(0.9,0.75,0.75),Color(0.75,0.75,0.9),Color(0.9,0.9,0.75)]);
//t.labelColors_([Color.red,Color.blue,Color.yellow]);

//t.tabHeight_(20);

// now add a tab and populate it with a slider;
var tab = tabView.add("test1", scroll:true); //scroll must be decided upon creation.
View(tab).layout_(VLayout(Button()));
//Slider(v, Rect(20,20,320,20));
Button(tab);

//add some closable tabs
//t.add("test2", scroll:true).closable_(true);
//t.add("test3", scroll:true).closable_(true);
//t.add("test4", scroll:true).closable_(true);

// override defaults in a custom tab
//m=t.add("Custom Configured Tab", scroll:true);
//m.labelColor=Color.green.alpha_(1);
//m.unfocusedColor=Color.green.alpha_(0.4);
//m.background=Color.green.alpha_(0.1);

tabView.front;
)


/////////////////////////////////////////
// triggers
(
MIDIdef.noteOn(\noteOn, {arg ...args;
	var note = args[1];
	var key = ('noteOn/' ++ note).asSymbol;
	[key].postln;
	Fdef(key).value();
});
MIDIdef.noteOff(\noteOff, {arg ...args;
	var note = args[1];
	var key = ('noteOff/' ++ note).asSymbol;
	[key].postln;
	Fdef(key).value();
});
)

MIDIIn.doNoteOnAction(1, 9, 64, 64); // spoof a note on
MIDIIn.doNoteOffAction(1, 1, 64, 64); // spoof a note on
MIDIIn.doControlAction(1, 1, 1, 64); // spoof a cc
MIDIIn.doControlAction(1, 1, 9, 64);
MIDIIn.doControlAction(1, 10, 1, 64);


