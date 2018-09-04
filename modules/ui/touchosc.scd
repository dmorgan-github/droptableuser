OSCdef.all;
OSCdef.freeAll;

/////////////////////////////////////////
// page 1: buttons
(
var grids = 1;
var rows = 4;
var cols = 7;
grids.do({arg k;

	var grid = k + 1;
	rows.do({arg i;
		var row = i + 1;
		cols.do({arg j;
			var col = j + 1;
			var key = ('/1/buttons' ++ grid).asSymbol;
			var addr = (key ++ '/' ++ row ++ '/' ++ col).asSymbol;
			OSCdef.newMatching(addr, {arg msg, time, addr, recvPort;
				Fdef(key).value(row-1, col-1, msg[1]);
			}, addr)
		});
	});
});

// faders
4.do({arg i;
	var num = i + 1;
	var key = ('/1/fader' ++ num).asSymbol;
	OSCdef.newMatching(key, {arg msg, time, addr, recvPort;
		[msg, time, addr, recvPort].debug(key);
		Fdef(key).value(msg[1]);
	}, key);
});

{
	var key = '/1/xy1';
	OSCdef.newMatching(key, {arg msg, time, addr, recvPort;
		//[msg, time, addr, recvPort].debug(key);
		Fdef(key).value(msg[1], msg[2]);
	}, key);
}.();

{
	var key = '/1/encoder1';
	OSCdef.newMatching(key, {arg msg, time, addr, recvPort;
		//[msg, time, addr, recvPort].debug(key);
		Fdef(key).value(msg[1]);
	}, key);
}.();

)

// test
(
Fdef('/1/buttons1', {arg row, col, val;
	[row, col, val].debug("/1/buttons1");
});
Fdef('/1/fader1', {arg val;
	val.debug("/1/fader1");
});
Fdef('/1/fader2', {arg val;
	val.debug("/1/fader2");
});
Fdef('/1/fader3', {arg val;
	val.debug("/1/fader3");
});
Fdef('/1/fader4', {arg val;
	val.debug("/1/fader4");
});
Fdef('/1/encoder1', {arg val;
	val.debug("/1/encoder1");
});
Fdef('/1/xy1', {arg x, y;
	[x,y].debug("/1/xy1");
});
)

/////////////////////////////////////////
// page 2: toggles
(
var grids = 4;
var rows = 4;
var cols = 4;
grids.do({arg k;

	var grid = k + 1;
	rows.do({arg i;
		var row = i + 1;
		cols.do({arg j;
			var col = j + 1;
			var key = ('/2/toggles' ++ grid).asSymbol;
			var addr = (key ++ '/' ++ row ++ '/' ++ col).asSymbol;
			OSCdef.newMatching(addr, {arg msg, time, addr, recvPort;
				Fdef(key).value(row-1, col-1, msg[1]);
			}, addr)
		});
	});

});
)

// test
(
Fdef('/2/toggles1', {arg row, col, val;
	[row, col, val].debug("/1/toggles1");
});
Fdef('/2/toggles2', {arg row, col, val;
	[row, col, val].debug("/1/toggles2");
});
Fdef('/2/toggles3', {arg row, col, val;
	[row, col, val].debug("/1/toggles3");
});
Fdef('/2/toggles4', {arg row, col, val;
	[row, col, val].debug("/1/toggles4");
});
)
