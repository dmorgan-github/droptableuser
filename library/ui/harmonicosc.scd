(
func: {|node|
    var vals = 16.collect({|val|
        var prop = "harm%".format(val+1);
        node.get(prop.asSymbol)
    }).postln;
    var view = View().layout_(VLayout(
        MultiSliderView()
        .elasticMode_(1)
        .valueThumbSize_(0.5)
        .value_(vals)
        .action_({|ctrl|
            var vals = ctrl.value;
            vals.do({|val, i|
                var key = "harm%".format(i + 1).asSymbol;
                node.set(key, val)
            })
        })
        .background_(Color.clear)
    ));
    view
    .bounds_(Rect(width:400, height:200))
    .background_(Color.clear)
}
)