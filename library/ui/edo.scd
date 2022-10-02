(
func: {|node|
    var incr = 7;
    var view = View().layout_(VLayout());
    var grid, div = 12;
    var spec = [3, 100, \lin, 1, 12].asSpec;
    var gridview = View(), updategrid;
    var octave = 3;

    updategrid = {
        var count = 0;
        var max = div+1;
        var rows = ((max/incr).ceil).asInteger;
        var data = rows.collect({|num|
            var val = incr;
            if ( (count + val) > max ) {
                val = (max - count);
            };
            count = count + val;
            val.collect({|k|
                Knob()
                .background_(Color.clear)
                .action_({|ctrl|
                    var degree = (num * incr + k);
                    var midinote = (
                        parent: Event.default,
                        scale: Scale((0..(div-1)), div),
                        degree: degree,
                        octave:octave
                    );
                    midinote = midinote.use({~midinote.value});
                    if (ctrl.value > 0) {
                        var vel = ctrl.value;
                        if (node.synths[midinote].notNil) {
                            //\here.postln;
                            node.synths[midinote].set(\vel, vel);
                        } {
                            vel = vel.linlin(0, 1, 0, 127);
                            node.on(midinote, vel)
                        }

                    } {
                        node.off(midinote);
                    }
                })
            })
        });

        gridview.children.do({|child|
            child.remove
        });

        gridview.layout = GridLayout.rows(*data.reverse).spacing_(0).margins_(0);
    };

    updategrid.();

    view.layout.add(
        HLayout(
            LevelSlider("edo", spec)
            .maxHeight_(15)
            .action_({|ctrl|
                div = ctrl.value.asInteger;
                updategrid.();
            })
            .value_(12),

            NumberBox()
            .clipLo_(1)
            .clipHi_(7)
            .minDecimals_(0)
            .fixedSize_(15)
            .background_(Color.clear)
            .value_(octave)
            .action_({|ctrl|
                octave = ctrl.value.asInteger
            })
        )
    );
    view.layout.add( gridview );
    view
    .front;
};
)