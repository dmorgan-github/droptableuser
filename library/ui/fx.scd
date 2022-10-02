(
func: {|node|

    var view = View()
    .layout_(VLayout()
        .margins_(1)
        .spacing_(1)
    );

    var swap, moveUp, moveDown, updateButtons, fxwatcher;
    var fxbuttonsview = View().layout_(VLayout().margins_(1).spacing_(1));
    var fxnode = if (node.respondsTo(\node)) { node.node }{ node };
    var fxmenu = Ui('fxmenu');
    var presetview = Ui('presets');

    swap = {|node, index2, index1|

        var fx1 = node.fxchain[index1];
        var fx2 = node.fxchain[index2];

        var obj1 = node.objects[index1];
        var obj2 = node.objects[index2];

        var synth1 = Synth.basicNew(obj1.synthDef.name, Server.default, obj1.nodeID);
        var synth2 = Synth.basicNew(obj2.synthDef.name, Server.default, obj2.nodeID);

        synth2.moveBefore(synth1);

        node.objects[index1] = obj2;
        node.objects[index2] = obj1;

        node.fxchain[index1] = fx2;
        node.fxchain[index2] = fx1;

        node.changed(\reorder)
    };

    moveUp = {|index|

        var num = fxnode.objects.indices.indexOf(index);
        var index2 = fxnode.objects.indices[num-1];

        if (index2.notNil) {
            swap.(fxnode, index, index2);
        } {
            "can't move node".warn;
        }
    };

    moveDown = {|index|

        var num = fxnode.objects.indices.indexOf(index);
        var index2 = fxnode.objects.indices[num+1];

        if (index2.notNil) {
            swap.(fxnode, index2, index);
        } {
            "can't move node".warn;
        }
    };

    updateButtons = {

        var ctrls = fxnode.fxchain;

        fxbuttonsview.children.do({|child|
            child.remove
        });

        if (ctrls.indices.size > 0) {

            ctrls.doRange({|obj, index, i|

                fxbuttonsview.layout.add(
                    HLayout(

                        StaticText()
                        .string_(obj.name.asString.split($.)[0].toUpper)
                        .stringColor_(Color.white.alpha_(0.5))

                        /*
                        Button()
                        .states_( [ [obj.name, Color.white.alpha_(0.5), Color.clear] ] )
                        .action_({|ctrl|
                            if (obj.type == 'vst') {
                                obj['ctrl'].editor
                            }{
                                var ctrl = obj['ctrl'];
                                if (ctrl.view.notNil) {
                                    var key = 'ui/' ++ ctrl.view;
                                    if (Module.exists(key)) {
                                        var fxview = Ui(ctrl.view).view(fxnode, index);
                                        fxview.bounds = Rect(view.bounds.left, view.bounds.top);
                                        fxview.front;
                                    } {
                                        "custom view does not exists: %".format(key).warn;
                                        Ui('sgui').gui(fxnode, index)
                                    }
                                }{
                                    var left, top;
                                    var fxview = Ui('sgui').view(fxnode, index);
                                    var parents = view.getParents();
                                    if (parents.notNil) {
                                        var width;
                                        var parent = parents.last;
                                        width = parent.bounds.width;
                                        left = parent.bounds.left + width + 5;
                                        top = parent.bounds.top;
                                    };
                                    fxview.bounds = Rect(left, top, 100, 200);
                                    fxview.front;
                                }

                            }
                        })
                        */
                        .mouseDownAction_({|ctrl, x, y, mod, num, count|

                            if (obj.type == 'vst') {
                                switch (mod,
                                    262144, { // ctrl key
                                        Ui('sgui').gui(fxnode, index)
                                    },
                                    524288, { // alt key
                                        obj['ctrl'].gui
                                    },
                                    {
                                        obj['ctrl'].editor
                                    }
                                )
                            }{
                                var ctrl = obj['ctrl'];
                                if (ctrl.view.notNil) {
                                    var key = 'ui/' ++ ctrl.view;
                                    if (Module.exists(key)) {
                                        var fxview = Ui(ctrl.view).view(fxnode, index);
                                        fxview.bounds = Rect(view.bounds.left, view.bounds.top);
                                        fxview.front;
                                    } {
                                        "custom view does not exists: %".format(key).warn;
                                        Ui('sgui').gui(fxnode, index)
                                    }
                                }{
                                    var left, top;
                                    var fxview = Ui('sgui').view(fxnode, index);
                                    var parents = view.getParents();
                                    if (parents.notNil) {
                                        var width;
                                        var parent = parents.last;
                                        width = parent.bounds.width;
                                        left = parent.bounds.left + width + 5;
                                        top = parent.bounds.top;
                                    };
                                    fxview.bounds = Rect(left, top, 100, 200);
                                    fxview.front;
                                }
                            }
                        }),

                        nil,

                        Button().states_([  ["↓", nil, Color.clear]  ]).action_({
                            moveDown.(index);
                        })
                        .maxWidth_(50),
                        Button().states_([  ["↑", nil, Color.clear]  ]).action_({
                            moveUp.(index);
                        })
                        .maxWidth_(50),

                        Button().states_([  ["x", nil, Color.clear]  ]).action_({
                            node.fx(index, nil)
                        })
                        .maxWidth_(50)
                        //.icon_(Image.new(App.librarydir ++ "images/noun_Delete_1982479.png")),
                    )
                );
            });
        };
    };

    updateButtons.();

    fxwatcher = {|obj, what|
        if (what == \source or: {what == \reorder}) {
            // there is a lag between when the source
            // gets added and the node is ready on the
            // server
            var wait = if (what == \reorder) {0.1}{1};
            {
                updateButtons.();
            }.defer(wait)
        }
    };

    fxnode.addDependant(fxwatcher);
    view.layout.add( fxmenu.view(fxnode) );
    view.layout.add( fxbuttonsview);
    view.layout.add( presetview.view(fxnode) );
    view.layout.add( nil);
    view
    .onClose_({
        fxnode.removeDependant(fxwatcher);
    });
}
)
