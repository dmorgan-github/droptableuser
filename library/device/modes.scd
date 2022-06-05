var getdata = {|scale='major', interval=7, root=36|

    var degrees, data, size;
    root = root ?? {'c1'.namemidi};
    interval = interval ?? {7};
    scale = scale ?? {'major'};

    // ensure we always have 7 scale degrees
    // there is probably a more elegant way to do this
    degrees = (Scale.at(scale.asSymbol).degrees ++ (Scale.at(scale.asSymbol).degrees + 12))[..6];
    size = degrees.size;
    data = degrees.collect({|degree|
        var val = root + degree + (interval * (0..(size-1)));
        val.nearestInScale(degrees);
    });
    data;
};

var connect = {|cb|

    var grid;
    var monome = Halo.at(\monome);
    if (monome.isNil) {
        "connecting...".debug("monome");
        MonoM.connect;
        {
            monome = MonoM.new("/monome", 0);
            monome.useDevice(0);
            "connected".debug("monome");
            Halo.put(\monome, monome);
            cb.(monome);
        }.defer(2)
    } {
        cb.(monome);
    }
};
/*
var config = [

        [
            (
                mode: 'push',
                scale: \aeolian,
                interval: 7,
                root: 36,
                on: {|note| \on.postln; },
                off: {|note| \off.postln;  }
            ),
            (
                mode: 'toggle',
                scale: \aeolian,
                interval: 7,
                root: 36,
                on: {|note| \on.postln; },
                off: {|note| \off.postln; }
            )
        ],

        [
            (
                mode: 'toggle',
                scale: \aeolian,
                interval: 7,
                root: 36,
                on: {|note| \on.postln; },
                off: {|note| \off.postln; }
            ),
            (
                mode: 'toggle',
                scale: \yu,
                interval: 7,
                root: 36,
                on: {|note| \on.postln; },
                off: {|note| \off.postln; }
            )
        ]

    ];
*/

(
func: {|config|

    var btninactive = 3;
    var btnactive = 6;
    var btnoff = 0;
    var panels;
    var gridrows = 8;
    var voicecols = 8;

    panels = 2.collect({|i|

        var voices;
        var panel = (
            active: 0
        );

        voices = config[i].collect({|voice|
            var scale = voice['scale'] ?? \major;
            var interval = voice['interval'] ?? 7;
            var root = voice['root'] ?? 36;
            var notes = getdata.(scale, interval, root);
            voice['notes'] = notes;
            voice['rows'] = notes.size;
            voice['cols'] = notes[0].size;
            voice['buttons'] = (voice['rows'] * voice['cols']).collect({0});
            voice;
            voice
        });

        panel['voices'] = voices;
        panel
    });

    connect.({|monome|

        "init".debug("modes");

        // levset can cause overload and crash monome
        // see https://llllllll.co/t/new-grid-leds-stops-working-serialosc-overload/47263/6

        monome.ledall(0);

        panels.do({|panel, i|

            var numvoices = panel['voices'].size;
            var voice = panel['voices'][0];
            var rows = voice['rows'];
            var cols = voice['cols'];
            var offset = voicecols*i;

            // page navigation
            numvoices.do({|col|
                var x = col+offset;
                var lev = if (col == 0) {btnactive}{btninactive};
                monome.levset(x, 0, lev);
            });

            /*
            // init grid buttons
            ((gridrows-rows)..7).do({|row|
                ((0..(cols-1))+offset).do({|col|
                    monome.levset(col, row, btninactive);
                });
            });
            */
        });
    });

    OSCdef(\modes, {|msg|

        var panel, voice, rows, cols;
        var activepanel, activevoice;
        var mode, notes, on, off, note;
        var noterow, notecol, num, voices, offset;

        var x = msg[1];
        var y = msg[2];
        var val = msg[3];
        var monome = Halo.at(\monome);

        activepanel = if (x >= voicecols) {1}{0};
        offset = activepanel*voicecols;
        panel = panels[activepanel];
        voices = panel['voices'];
        activevoice = panel['active'];
        voice = panel['voices'][activevoice];
        rows = voice['rows'];
        cols = voice['cols'];

        // page navigation
        if (y == 0 and: {val == 1}) {

            if (x.mod(voicecols) < voices.size) {

                // TODO: rewrite with levmap
                //monome.levmap(8, 0, Array.fill(64, {3}));
                activevoice = x.mod(voicecols);
                panel['active'] = activevoice;
                monome.ledmap(offset, 0, [0, 0, 0, 0, 0, 0, 0, 0]);

                voice = voices[activevoice];
                rows = voice['rows'];
                cols = voice['cols'];

                (1..7).do({|row|
                    ((0..6)+offset).do({|col|
                        var num = (col.mod(voicecols)) + ((row-1)*rows);
                        if (voice['buttons'][num] > 0) {
                            monome.levset(col, gridrows-row, btnactive);
                        }
                    });
                });

                // update navigation
                voices.size.do({|val|
                    monome.levset(val+offset, 0, btninactive);
                });
                monome.levset(x, 0, btnactive);
            }
        };

        mode = voice['mode'] ?? \push;
        notes = voice['notes'];
        on = voice['on'] ?? { {|note| note.debug(\on) } };
        off = voice['off'] ?? { {|note| note.debug(\off) } };
        noterow = (gridrows-1-y);
        notecol = x.mod(voicecols);

        num = (noterow * rows) + notecol;
        note = notes.wrapAt(noterow).wrapAt(notecol);

        if (noterow < rows and: {notecol < cols}) {

            if (mode == \push) {
                if (val == 1) {
                    //note.asInteger.midiname.postln;
                    on.(note);
                    voice['buttons'][num] = 1;
                }{
                    off.(note);
                    voice['buttons'][num] = 0;
                };
                monome.levset(x, y, if (voice['buttons'][num] > 0){btnactive}{btnoff} );
            }{
                // toggle mode
                if (val == 1) {
                    voice['buttons'][num] = (1-voice['buttons'][num]);
                    monome.levset(x, y, if (voice['buttons'][num] > 0){btnactive}{btnoff});

                    if (voice['buttons'][num] > 0) {
                        on.(note);
                    }{
                        off.(note)
                    };
                };
            }
        }

    }, '/monome/grid/key')
}
)

/*
var getdata = {|scale='major', interval=7, root=36|

    var degrees, data, size;
    root = root ?? {'c1'.namemidi};
    interval = interval ?? {7};
    scale = scale ?? {'major'};

    degrees = Scale.at(scale.asSymbol).degrees;// ++ [12];
    size = degrees.size;
    data = degrees.collect({|degree|
        var val = root + degree + (interval * (0..(size-1)));
        val.nearestInScale(degrees);
    });
    data;
};

var connect = {|cb|

    var grid;
    var monome = Halo.at(\monome);
    if (monome.isNil) {
        "connecting...".debug("monome");
        MonoM.connect;
        {
            monome = MonoM.new("/monome", 0);
            monome.useDevice(0);
            "connected".debug("monome");
            Halo.put(\monome, monome);
            cb.(monome);
        }.defer(2)
    } {
        cb.(monome);
    }
};

(

/*
Module('device/modes')
.put('pages',
    [
        [
            (
                mode: 'push',
                scale: \aeolian,
                interval: 7,
                root: 36,
                on: {|note| ~dx.on(note) },
                off: {|note| ~dx.off(note)}
            ),
            (
                mode: 'toggle',
                scale: \aeolian,
                interval: 7,
                root: 36,
                on: {|note| ~dx.on(note) },
                off: {|note| ~dx.off(note)}
            )
        ]
    ]
)
.()
*/

func: {

    var inactive = 1;
    var active = 6;
    var pages = ~pages.collect({|val|
        val.collect({|config|
            var scale = config['scale'];
            var interval = config['interval'];
            var root = config['root'];
            var data = getdata.(scale, interval, root);
            config['data'] = data;
            config;
        })
    });

    var numpages = pages.size;
    var activepage = 0;
    var numvoices = 2;
    var gridrows = 8;
    var voicecols = 8;
    var pagecols = voicecols * numvoices;
    var pagebuttons = pagecols * gridrows;
    var buttons = Array.fill(pagebuttons * numpages, {0});
    var activevoice = 0;
    var page, voice;

    page = pages[activepage];

    connect.({|monome|
        //monome.levset(0, 0, 6);

        page.do({|config, i|

            var data = config['data'];
            var rows = data.size;
            var cols = data[0].size;
            var offset = 8*i;

            (1..7).do({|row|
                ((0..6)+offset).do({|col|
                    monome.levset(col, row, 0);
                })
            });

            ((8-rows)..7).do({|row|
                ((0..(cols-1))+offset).do({|col|
                    monome.levset(col, row, inactive);
                });
            });
        });

        /*
        (1..7).do({|row|
            (0..6).do({|col|
                monome.levset(col, row, inactive);
            })
        })
        */

    });

    OSCdef(\modes, {|msg|

        var mode, data, on, off;

        var x = msg[1];
        var y = msg[2];
        var val = msg[3];

        var num, note;
        var activevoice = if (x >= voicecols) {1}{0};

        page = pages[activepage];
        voice = page[activevoice];

        mode = voice['mode'] ?? { \push };
        data = voice['data'];
        on = voice['on'] ?? { {|note| note.debug(\on) } };
        off = voice['off'] ?? { {|note| note.debug(\off) } };

        num = pagecols * (gridrows-1-y) + (x) + (pagebuttons*activepage);
        note = data.wrapAt(gridrows-1-y).wrapAt(x.mod(voicecols));

        if (gridrows-1-y < data.size and: {x.mod(voicecols) < data[0].size}) {

            var monome = Halo.at(\monome);

            if (mode == \push) {
                if (val == 1) {
                    //note.asInteger.midiname.postln;
                    on.(note);
                    buttons[num] = 1;
                }{
                    off.(note);
                    buttons[num] = 0;
                };
                monome.levset(x, y, if (buttons[num] > 0){active}{inactive}  );
            }{
                // toggle mode
                if (val == 1) {
                    buttons[num] = (1-buttons[num]);
                    monome.levset(x, y, if (buttons[num] > 0){active}{inactive});//~buttons[num].debug(\here);

                    if (buttons[num] > 0) {
                        on.(note);
                    }{
                        off.(note)
                    };
                };
            }
        }

    }, '/monome/grid/key')

}
)
*/
