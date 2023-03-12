
(
func: {|node, index, cmds|

    var cmdhistory = List.new;
    var currentindex = 0;
    var currentcmd;
    var fxnode = node.node;
    var windowname = if (index.notNil) {
        "%/%".format(node.key, fxnode.fxchain[index].name);
    }{
        node.key
    };
    var view, target, props, scope, meter;
    var getView, presets, freq, fx, views=[];
    var parse;

    meter = UiModule('meter').view(node);
    props = UiModule('props').view(node, index);
    fx = UiModule('fx').view(node);
    presets = UiModule('presets').view(node);
    freq = UiModule('freqscope').view(node).maxHeight_(80);
    if (index.isNil) {
        views = [presets, freq, fx];
    };

    target = View().layout_(VLayout(*views).margins_(0).spacing_(0));

    parse = {|str|

        var exec, match;
        var getNextToken;
        var hasMoreTokens;
        var spec;
        var cursor = 0;

        // as pairs
        spec = [
            'string', "^[a-zA-Z0-9\/]+",
            '[', "^\\[",
            ']', "^\\]",
            '(', "^\\(",
            ')', "^\\)",
            nil, "^\\s+",
            nil, "^\,",

        ];

        hasMoreTokens = {
            cursor < str.size;
        };

        match = {|regex, str|
            var val = nil;
            var m = str.findRegexp(regex);
            if (m.size > 0) {
                val = m[0][1];
                cursor = cursor + val.size;
            };
            val;
        };

        getNextToken = {
            var getNext;
            var result = nil;
            getNext = {
                if (hasMoreTokens.()) {
                    spec.pairsDo({|k, v|
                        if (result.isNil) {
                            var val = match.(v, str[cursor..]);
                            //[k, v, val].debug("match");
                            if (val.notNil) {
                                if (k.isNil) {
                                    getNext.()
                                }{
                                    result = (
                                        type: k,
                                        val: val
                                    );
                                }
                            }
                        }
                    });
                };
            };

            getNext.();

            if (result.isNil) {
                "unexpected token %".format(str[cursor]).throw
            };
            result;
        };

        exec = {|list|

            var exit = false;
            while ({ hasMoreTokens.() and: { exit.not } }, {
                var token = getNextToken.();
                //token.debug("token");
                switch(token['type'],
                    // entities
                    'string', {
                        var ui = token['val'];
                        ui = ui.asString.split($/);
                        list.add( getView.(ui[0], ui[1]) )
                    },
                    // grouping delimiters
                    '[', {
                        var result;
                        result = exec.(HLayout());
                        list.add(result);
                    },
                    ']', {
                        list.add(nil);
                        exit = true;
                    },
                    '(', {
                        var result;
                        result = exec.(VLayout());
                        list.add(result);
                    },
                    ')', {
                        list.add(nil);
                        exit = true
                    }
                );
            });

            list;
        };
        exec.(VLayout());
    };

    getView = {|currentcmd, args|
        //currentcmd.debug("getView");
        switch (currentcmd.asSymbol,
            \freq, {
                UiModule(\freqscope).view(node)
            },
            \grain, {
                UiModule(\grainsliders).view(node)
            },
            \home, {
                var freq, fx, presets;
                freq = UiModule('freqscope').view(node).maxHeight_(80);
                fx = UiModule('fx').view(node);
                presets = UiModule('presets').view(node);
                VLayout(presets, freq, fx)
            },
            {
                UiModule(currentcmd).view(node, args)
            }
        );
    };

    if (index.isNil) {
        views = [
            meter.fixedWidth_(175),
            props.fixedWidth_(175).background_(Color.black)  ]
    }{
        views = [props.minWidth_(175).background_(Color.black)]
    };

    view = View(bounds:75@150)
    .name_(windowname)
    .layout_(VLayout(
        HLayout(
            VLayout(*views),
            target
        ).margins_(5).spacing_(5),

        TextField()
        .keyDownAction_({|ctrl, char, mod, unicode, keycode, key|

            // 16777235 up
            // 16777237

            if (keycode == 126) {
                var cmd = cmdhistory.wrapAt(currentindex);
                ctrl.value = cmd;
                currentindex = (currentindex - 1).clip(0, cmdhistory.size);
            };

            if (keycode == 125) {
                var cmd = cmdhistory.wrapAt(currentindex);
                ctrl.value = cmd;
                currentindex = (currentindex + 1).clip(0, cmdhistory.size);
            };

            if (keycode == 36) {
                //[ctrl, char, mod, unicode, keycode, key].postln;
                //var args = "[" ++ ctrl.value ++ "]";
                // it seems we need asCompileString to handle symbols
                // and then we need to do interpret twice since
                // the first call returns a string when needs
                // to be interpreted as an array.
                //args = args.asCompileString.interpret.interpret;
                //args.postln;
                //node.set(*args)
                var parts, lhs, rhs;
                var val = ctrl.value.asSymbol;
                var view;
                currentcmd = val;

                cmdhistory.add(currentcmd);
                currentindex = cmdhistory.size -1;

                switch (currentcmd,
                    \play, {
                        node.play
                    },
                    \stop, {
                        node.stop
                    },
                    \close, {
                        target.children.do({|child|
                            child.remove
                        });
                    },
                    {
                        var cmd = val.asString;
                        cmd.debug("cmd");

                        case(

                            {cmd.beginsWith("@")}, {
                                var parts = cmd.split(Char.space);
                                var lhs = parts[0];
                                var rhs = parts[1..].join("");
                                var lhsparts = lhs.split($.);
                                var prop = lhsparts[1];
                                if (rhs.isNil or: {rhs == ""}) {
                                    var val = node.get(prop.asSymbol);
                                    ctrl.value = "@.% %".format(prop, val);
                                } {
                                    node.set(prop.asSymbol, rhs.interpret);
                                }
                            },

                            {cmd.beginsWith("mute")}, {
                                var fadetime = 1;
                                var cmd = val.asString;
                                parts = cmd.split(Char.space);
                                lhs = parts[0];
                                rhs = parts[1..].join("");
                                if (rhs.notNil) {
                                    fadetime = rhs.asFloat;
                                };
                                fxnode.stop(fadeTime:fadetime.debug("fadetime"))
                            },

                            {cmd.beginsWith("unmute")}, {
                                var fadetime = 1;
                                var cmd = val.asString;
                                parts = cmd.split(Char.space);
                                lhs = parts[0];
                                rhs = parts[1..].join("");
                                if (rhs.notNil) {
                                    fadetime = rhs.asFloat;
                                };
                                fxnode.play(fadeTime:fadetime.debug("fadetime"))
                            },
                            {
                                var layout;
                                target.children.do({|child|
                                    child.remove
                                });
                                layout = parse.(cmd.asString);
                                target.layout.add( layout );
                            }

                            /*
                            {cmd.beginsWith("split")}, {

                                var parts = cmd.split(Char.space);
                                var lhs = parts[0];
                                var rhs = parts[1..].join("");
                                var vals = rhs.interpret;

                                if (lhs == "split-h") {

                                    target.children.do({|child|
                                        child.remove
                                    });
                                    vals.do({|val|
                                        var view = getView.(val);
                                        target.layout.add(view);
                                    });
                                    target.layout.add(nil);
                                } {
                                    if (lhs == "split-v") {

                                    }
                                }

                            }, {
                                var myviews;
                                var args;
                                var mycmd;
                                target.children.do({|child|
                                    child.remove
                                });
                                mycmd = cmd.asString.split($/);
                                currentcmd = mycmd[0].asSymbol;
                                if (mycmd.size > 1) {
                                    args = mycmd[1];
                                };
                                //[cmd, mycmd, args].postln;
                                target.layout.add( getView.(currentcmd, args) );
                            }
                            */
                        );
                    }
                );
            }
        }).background_(Color.clear)
    ).margins_(0).spacing_(0)
    )
    .background_(Color.black);

    view;
}
)
