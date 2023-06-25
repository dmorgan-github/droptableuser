var getdata = {|scale='major', interval=7, root=36|

    var degrees, data, size;
    root = root ?? {'c1'.namemidi};
    interval = interval ?? {7};
    scale = scale ?? {'major'};
 
    if (scale == \grid) {
        data = 7.collect({|i|
            7.collect({|k|
                k + (i * 7)    
            })
        })
    } {
        // ensure we always have 7 scale degrees
        // there is probably a more elegant way to do this
        var vals;
        degrees = (Scale.at(scale.asSymbol).degrees ++ (Scale.at(scale.asSymbol).degrees + 12))[..6];
        size = degrees.size;
        data = degrees.collect({|degree|
            var val = root + degree + (interval * (0..(size-1)));
            val.nearestInScale(degrees);
        });

        vals = (0..3).collect({|v| 
            degrees + (12 * v)
        })
        .inject([], {|a, b| a ++ b  });

        data = degrees.collect({|d, i|
            vals[i..].select({|v, i| i.mod(interval) == 0})[..6]
        }) + root;
    };

    data
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
func: {|config|

    var btninactive = 3;
    var btnactive = 6;
    var btnoff = 0;
    var panels;
    var gridrows = 8;
    var voicecols = 8;
    var size; 

    size = min(config.size, 2);

    panels = size.collect({|i|

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
            var numvoices, voice, rows, cols, offset; 
            numvoices = panel['voices'].size;
            voice = panel['voices'][0];
            rows = voice['rows'];
            cols = voice['cols'];
            offset = voicecols*i;

            // page navigation
            numvoices.do({|col|
                var x = col+offset;
                var lev = if (col == 0) {btnactive}{btninactive};
                monome.levset(x, 0, lev);
            });
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

        if (panel.isNil) {
            "panel not configured".warn
        } {
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
        }

    }, '/monome/grid/key')
},

doc: "
var config = [

    [
        (
            mode: 'push',
            scale: \\aeolian,
            interval: 4,
            root: 36,
            on: {|note| \\on.postln; },
            off: {|note| \\off.postln;  }
        ),
        (
            mode: 'toggle',
            scale: \\aeolian,
            interval: 4,
            root: 36,
            on: {|note| \\on.postln; },
            off: {|note| \\off.postln; }
        )
    ],

    [
        (
            mode: 'toggle',
            scale: \\aeolian,
            interval: 4,
            root: 36,
            on: {|note| \\on.postln; },
            off: {|note| \\off.postln; }
        ),
        (
            mode: 'toggle',
            scale: \\yu,
            interval: 2,
            root: 36,
            on: {|note| \\on.postln; },
            off: {|note| \\off.postln; }
        )
    ]
];
DMModule('device/modes').(config)
"
)
