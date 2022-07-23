(
func: {|node|

    var keys = [
        \pitch,
        \pbstretch,
        \grainrate,
        \graindur,
        \async,
        //\startPos,
        \prob,
    ];

    var vals = keys
    .collect({|key|
        var spec = node.getSpec(key);
        var val = node.get(key);
        [key, spec].debug("grainsliders");
        if (spec.notNil) {
            val = spec.unmap(val);
        };
        val
    });

    MultiSliderView()
    .value_(vals)
    .elasticMode_(1)
    .valueThumbSize_(0.5)
    .action_({|ctrl|
        ctrl.value.do({|val, i|
            var key = keys[i];
            var spec = node.getSpec(key);
            val = spec.map(val);
            node.set(key, val);
        })
    })
    .background_(Color.clear)

}
)
