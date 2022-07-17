(
// TODO: this needs lots of work
func: {|node,nums|

   // var nums = [8, 3];
    //var nums = node.get(\seqnum) ?? [8];
    var view = View().layout_(VLayout().margins_(0).spacing_(0)).background_(Color.black);
    var sliders;
    var buttons;
    var spawner, vals;
    var player;

    vals = nums.collect({|num|
        num.collect( { rrand(0.0, 1.0) } )
    });
    buttons = nums.collect({|val|
        val.collect({
            Button()
            .maxHeight_(5)
            .maxWidth_(22)
            .states_( [ [nil, nil, Color.clear], [nil, nil, Color.cyan] ] )
        })
    });

    nums.do({|num, i|

        var btns;
        var ctrlView = View().layout_(VLayout()).maxWidth_(num * 22);

        sliders = MultiSliderView()
        .value_( vals[i] )
        .elasticMode_(1)
        .valueThumbSize_(0.5)
        .action_({|ctrl|
            vals[i] = ctrl.value;
        })
        .background_(Color.clear);

        btns = buttons[i].collect({|v| v});
        ctrlView.layout.add(sliders);
        ctrlView.layout.add(
            HLayout(*btns)
            .margins_(0)
            .spacing_(0)
        );

        view.layout.add(ctrlView);
    });

    if (node.get(\seqview).isNil) {

        var ptrn = Pspawner({|sp|
            inf.do({|i|

                var myvals = vals.collect({|val|
                    val.wrapAt(i)
                });

                buttons.do({|btns|
                    {
                        btns.wrapAt(i-1).value = 0;
                        btns.wrapAt(i).value = 1;
                    }.defer;
                });

                sp.seq( Pbind(\vals, myvals, \foo, Pn(1, 1)) );
            });
        });

        node.source = ptrn;
        node.set(\seqview, 1);
    };

    view
}
)
