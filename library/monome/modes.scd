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
Module('monome/modes')
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


/*

(
func: {

    var pages = [
        [
            (
                mode: 'push',
                scale: \aeolian,
                interval: 7,
                root: 36,
                on: {},
                of: {}
            ),
            (
                mode: 'push',
                scale: \aeolian,
                interval: 7,
                root: 36,
                on: {},
                off: {}
            )
        ]
    ];

    var activepage = 0;


    //var mode = ~mode;
    //var on = ~on ?? { {|note| note.debug(\on) } };
    //var off = ~off ?? { {|note| note.debug(\off) } };
    //var data = getdata.(~scale, ~interval, ~root);
    var numvoices = 2;
    var gridrows = 7;
    var voicecols = 8;
    var gridcols = voicecols * numvoices;
    var numbuttons = gridrows * gridcols;
    var buttons = Array.fill(numbuttons, {0});
    connect.();

    OSCdef(\modes, {|msg|

        var x = msg[1];
        var y = msg[2];
        var val = msg[3];
        var row = gridrows-1-y;
        var col = x;
        var page = pages[activepage];
        var activevoice = if (col >= voicecols) {1}{0};
        var voice = pages[activepage][activevoice];
        var mode = voice['mode'];
        var on = voice['on'];
        var off = voice['off'];
        var data = voice['data'];

        var getNote = {|x, y, data|
            var note;
            if (if (y < data.size) and: { x < data[0].size }) {
                note = data.wrapAt(7-y).wrapAt(x);
            };
            note;
        };

        var getButton = {|x, y, page, voice|
            var num = numbuttons - ((gridcols-x) + (gridcols * y));
            num;
        };

        note = getNote.(col.mod(8), y, data);


        if ((gridrows-1-y) < data.size and: {x < data[0].size}) {

            var num = numbuttons - ((gridcols-x) + (gridcols * y));
            var note = data.wrapAt(7-y).wrapAt(x);
            var monome = Halo.at(\monome);

            if (mode == \push) {
                if (val == 1) {
                    buttons[num] = 1;
                    on.(note);
                }{
                    buttons[num] = 0;
                    off.(note)
                };
                monome.levset(x, y, buttons[num] * 6);
            }{
                // toggle mode
                if (val == 1) {
                    buttons[num] = (1-buttons[num]);
                    monome.levset(x, y, buttons[num] * 6);//~buttons[num].debug(\here);

                    if (buttons[num] > 0) {
                        on.(note);
                    }{
                        off.(note)
                    };
                };
            };
        }

    }, '/monome/grid/key')
    .permanent_(true);
}
)
*/