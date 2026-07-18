
// SC port of instr_controller/src/adsrEditor.ts
// propPrefix: "" for amplitude EG, "f" for filter EG.

AdsrEditor : View {

    classvar minT = 0.001, dragRes = 4;

    // ADSR state as instance variables — avoids Event dot-notation issues
    var atkVal, decVal, susVal, relVal, crvAVal, crvDVal, crvRVal;

    // Drag state as instance variables
    var dragType, dragSX, dragSY;
    var dragAtk, dragDec, dragSus, dragRel, dragCrvA, dragCrvD, dragCrvR;
    var dragPsc, dragPlotH;
    var dragSegAspan, dragSegDspan, dragSegRspan;

    var canvas, boxes, oscTask, instrProxy, propPrefix;

    *new { |instrProxy, propPrefix = ""|
        ^super.new().prInit(instrProxy, propPrefix)
    }

    prInit { |argInstrProxy, argPropPrefix|
        instrProxy = argInstrProxy;
        propPrefix = argPropPrefix;
        atkVal  = 0.01;  decVal  = 0.3;
        susVal  = 0.7;   relVal  = 0.5;
        crvAVal = 0.0;   crvDVal = -4.0;  crvRVal = -4.0;
        boxes    = ();
        dragType = nil;
        oscTask  = nil;
        this.layout_(VLayout(
            this.prBuildCanvas,
            this.prBuildControls
        ).margins_(2).spacing_(2));
        AppClock.sched(0.05, { canvas.refresh; nil })
    }

    // SC Env exponential formula
    prScY { |y0, y1, t, c|
        if (c.abs < 0.001) { ^y0 + ((y1 - y0) * t) };
        ^y0 + ((y1 - y0) * (1 - (c * t).exp) / (1 - c.exp))
    }

    // Normalised midpoint value: 1 / (1 + exp(c/2))
    prScMid { |c|
        if (c.abs < 0.001) { ^0.5 };
        ^1 / (1 + (c * 0.5).exp)
    }

    // Returns Array of layout values (indexed constants below)
    // [0]px0 [1]pxA [2]pxD [3]px1 [4]pyB [5]pyT [6]pyS
    // [7]psc [8]plotH
    // [9]bmAx [10]bmAy [11]bmDx [12]bmDy [13]bmRx [14]bmRy
    // [15]segAspan [16]segDspan [17]segRspan
    prLayout { |w, h|
        var padL = 8, padR = 8, padT = 10, padB = 20;
        var plotW = w - padL - padR;
        var plotH = h - padT - padB;
        var total = (atkVal + decVal + relVal).max(0.001);
        var psc   = plotW / (total * 2);
        var px0   = padL;
        var pxA   = padL + (atkVal * psc);
        var pxD   = pxA  + (decVal * psc);
        var px1   = padL + (total  * psc);
        var pyB   = h - padB;
        var pyT   = padT;
        var pyS   = pyB - (susVal * plotH);
        ^[
            px0, pxA, pxD, px1,
            pyB, pyT, pyS,
            psc, plotH,
            (px0+pxA)/2,  pyB + ((pyT-pyB) * this.prScMid(crvAVal)),
            (pxA+pxD)/2,  pyT + ((pyS-pyT) * this.prScMid(crvDVal)),
            (pxD+px1)/2,  pyS + ((pyB-pyS) * this.prScMid(crvRVal)),
            pyT-pyB, pyS-pyT, pyB-pyS
        ]
    }

    prBuildCanvas {
        canvas = UserView()
        .minHeight_(110)
        .background_(Color.black)
        .drawFunc_({ |v|
            try { this.prDraw(v.bounds.width, v.bounds.height) } { |e| e.postln }
        })
        .onResize_({ canvas.refresh })
        .mouseDownAction_({ |v, mx, my|
            this.prMouseDown(mx, my, v.bounds.width, v.bounds.height)
        })
        .mouseMoveAction_({ |v, mx, my| this.prMouseMove(mx, my) })
        .mouseUpAction_({ dragType = nil });
        ^canvas
    }

    prDraw { |w, h|
        var lo, px0, pxA, pxD, px1, pyB, pyT, pyS;
        var bmAx, bmAy, bmDx, bmDy, bmRx, bmRy;
        var n, pts, green, cyan, dim;

        if (w <= 0 or: { h <= 0 }) { ^this };
        lo   = this.prLayout(w, h);
        px0  = lo[0];  pxA = lo[1];  pxD = lo[2];  px1 = lo[3];
        pyB  = lo[4];  pyT = lo[5];  pyS = lo[6];
        bmAx = lo[9];  bmAy = lo[10];
        bmDx = lo[11]; bmDy = lo[12];
        bmRx = lo[13]; bmRy = lo[14];

        green = Color(0.24, 0.86, 0.52);
        cyan  = Color(0.31, 0.79, 0.69);
        dim   = Color.gray(0.5);
        n     = 32;
        pts   = [];

        (n+1).do { |i|
            var t = i / n;
            pts = pts.add(Point(px0 + (t*(pxA-px0)), this.prScY(pyB, pyT, t, crvAVal)))
        };
        1.to(n).do { |i|
            var t = i / n;
            pts = pts.add(Point(pxA + (t*(pxD-pxA)), this.prScY(pyT, pyS, t, crvDVal)))
        };
        1.to(n).do { |i|
            var t = i / n;
            pts = pts.add(Point(pxD + (t*(px1-pxD)), this.prScY(pyS, pyB, t, crvRVal)))
        };

        // Fill
        Pen.color_(Color(0.24, 0.86, 0.52, 0.15));
        Pen.moveTo(pts[0]);
        pts.do { |p| Pen.lineTo(p) };
        Pen.lineTo(Point(px0, pyB));
        Pen.fill;

        // Stroke
        Pen.color_(green);
        Pen.width_(1.5);
        Pen.moveTo(pts[0]);
        pts.do { |p| Pen.lineTo(p) };
        Pen.stroke;

        // Sustain line
        Pen.color_(Color(0.24, 0.86, 0.52, 0.35));
        Pen.width_(0.75);
        Pen.moveTo(Point(pxD, pyS));
        Pen.lineTo(Point(px1, pyS));
        Pen.stroke;

        // Curve handle leaders
        Pen.color_(Color.gray(0.5, 0.5));
        Pen.width_(0.75);
        Pen.moveTo(Point((px0+pxA)/2, (pyB+pyT)/2)); Pen.lineTo(Point(bmAx,bmAy)); Pen.stroke;
        Pen.moveTo(Point((pxA+pxD)/2, (pyT+pyS)/2)); Pen.lineTo(Point(bmDx,bmDy)); Pen.stroke;
        Pen.moveTo(Point((pxD+px1)/2, (pyS+pyB)/2)); Pen.lineTo(Point(bmRx,bmRy)); Pen.stroke;

        // Curve handles
        [[bmAx,bmAy],[bmDx,bmDy],[bmRx,bmRy]].do { |pr|
            var pt = Point(pr[0], pr[1]);
            Pen.color_(Color.black);
            Pen.addOval(Rect.aboutPoint(pt, 4, 4)); Pen.fill;
            Pen.color_(cyan); Pen.width_(1.5);
            Pen.addOval(Rect.aboutPoint(pt, 4, 4)); Pen.stroke
        };

        // Main drag points
        [[pxA,pyT],[pxD,pyS],[px1,pyB]].do { |pr|
            var pt = Point(pr[0], pr[1]);
            Pen.color_(Color.black);
            Pen.addOval(Rect.aboutPoint(pt, 5, 5)); Pen.fill;
            Pen.color_(green); Pen.width_(1.5);
            Pen.addOval(Rect.aboutPoint(pt, 5, 5)); Pen.stroke
        };

        // Labels
        Pen.color_(dim);
        Pen.font_(Font.default.size_(9));
        Pen.stringAtPoint("A", Point((px0+pxA)/2 - 3, pyB + 4));
        Pen.stringAtPoint("D", Point((pxA+pxD)/2 - 3, pyB + 4));
        Pen.stringAtPoint("R", Point((pxD+px1)/2 - 3, pyB + 4))
    }

    prMouseDown { |mx, my, w, h|
        var lo, pxA, pxD, px1, pyB, pyT, pyS;
        var bmAx, bmAy, bmDx, bmDy, bmRx, bmRy;
        var r2 = 64, hit;

        lo   = this.prLayout(w, h);
        pxA  = lo[1];  pxD = lo[2];  px1 = lo[3];
        pyB  = lo[4];  pyT = lo[5];  pyS = lo[6];
        bmAx = lo[9];  bmAy = lo[10];
        bmDx = lo[11]; bmDy = lo[12];
        bmRx = lo[13]; bmRy = lo[14];

        hit = nil;
        if (((mx-pxA).squared + (my-pyT).squared) <= r2) { hit = \ptA };
        if (hit.isNil and: {((mx-pxD).squared + (my-pyS).squared) <= r2}) { hit = \ptD };
        if (hit.isNil and: {((mx-px1).squared + (my-pyB).squared) <= r2}) { hit = \ptS };
        if (hit.isNil and: {((mx-bmAx).squared + (my-bmAy).squared) <= r2}) { hit = \chA };
        if (hit.isNil and: {((mx-bmDx).squared + (my-bmDy).squared) <= r2}) { hit = \chD };
        if (hit.isNil and: {((mx-bmRx).squared + (my-bmRy).squared) <= r2}) { hit = \chR };

        if (hit.notNil) {
            dragType = hit;
            dragSX   = mx;       dragSY   = my;
            dragAtk  = atkVal;   dragDec  = decVal;
            dragSus  = susVal;   dragRel  = relVal;
            dragCrvA = crvAVal;  dragCrvD = crvDVal;  dragCrvR = crvRVal;
            dragPsc    = lo[7];
            dragPlotH  = lo[8];
            dragSegAspan = lo[15];
            dragSegDspan = lo[16];
            dragSegRspan = lo[17]
        }
    }

    prMouseMove { |mx, my|
        var dx, dy, span, f0, f;
        if (dragType.isNil) { ^this };
        dx = mx - dragSX;
        dy = my - dragSY;
        switch(dragType,
            \ptA, { atkVal = (dragAtk + (dx / dragPsc)).clip(minT, 8) },
            \ptD, {
                decVal = (dragDec + (dx / dragPsc)).clip(minT, 8);
                susVal = (dragSus - (dy / dragPlotH)).clip(0, 1)
            },
            \ptS, { relVal = (dragRel + (dx / dragPsc)).clip(minT, 8) },
            \chA, {
                span = dragSegAspan;
                if (span.abs >= 1) {
                    f0 = this.prScMid(dragCrvA);
                    f  = (f0 + (dy / (span * dragRes))).clip(0.001, 0.999);
                    crvAVal = (2 * ((1-f)/f).log).clip(-8, 8)
                }
            },
            \chD, {
                span = dragSegDspan;
                if (span.abs >= 1) {
                    f0 = this.prScMid(dragCrvD);
                    f  = (f0 + (dy / (span * dragRes))).clip(0.001, 0.999);
                    crvDVal = (2 * ((1-f)/f).log).clip(-8, 8)
                }
            },
            \chR, {
                span = dragSegRspan;
                if (span.abs >= 1) {
                    f0 = this.prScMid(dragCrvR);
                    f  = (f0 + (dy / (span * dragRes))).clip(0.001, 0.999);
                    crvRVal = (2 * ((1-f)/f).log).clip(-8, 8)
                }
            }
        );
        this.prSyncBoxes;
        canvas.refresh;
        this.prSchedOsc
    }

    prBuildControls {
        var defs, items;
        defs = [
            [\attack,  "Atk",  0.001, 8.0,  0.001, 3],
            [\decay,   "Dec",  0.001, 8.0,  0.001, 3],
            [\sustain, "Sus",  0.0,   1.0,  0.01,  3],
            [\release, "Rel",  0.001, 8.0,  0.001, 3],
            [\curveA,  "cA",  -8.0,  8.0,  0.1,   2],
            [\curveD,  "cD",  -8.0,  8.0,  0.1,   2],
            [\curveR,  "cR",  -8.0,  8.0,  0.1,   2]
        ];
        items = defs.collect { |def|
            var sym = def[0], lbl = def[1], mn = def[2],
                mx = def[3], step = def[4], dec = def[5];
            var nb = NumberBox()
                .value_(this.prGet(sym))
                .step_(step)
                .scroll_step_(step * 10)
                .clipLo_(mn).clipHi_(mx)
                .minDecimals_(dec).maxDecimals_(dec)
                .action_({ |ctrl|
                    this.prSet(sym, ctrl.value);
                    canvas.refresh;
                    this.prSchedOsc
                });
            boxes.put(sym, nb);
            View().layout_(VLayout(
                StaticText().string_(lbl).align_(\center)
                    .stringColor_(Color.gray(0.6)).font_(Font.default.size_(9)),
                nb
            ).spacing_(1).margins_(0))
        };
        ^View().layout_(HLayout(*items).margins_(2).spacing_(4))
    }

    prGet { |sym|
        switch(sym,
            \attack,  { ^atkVal  }, \decay,   { ^decVal  },
            \sustain, { ^susVal  }, \release, { ^relVal  },
            \curveA,  { ^crvAVal }, \curveD,  { ^crvDVal },
            \curveR,  { ^crvRVal }
        )
    }

    prSet { |sym, val|
        switch(sym,
            \attack,  { atkVal  = val }, \decay,   { decVal  = val },
            \sustain, { susVal  = val }, \release, { relVal  = val },
            \curveA,  { crvAVal = val }, \curveD,  { crvDVal = val },
            \curveR,  { crvRVal = val }
        )
    }

    prSyncBoxes {
        boxes.at(\attack).value  = atkVal;
        boxes.at(\decay).value   = decVal;
        boxes.at(\sustain).value = susVal;
        boxes.at(\release).value = relVal;
        boxes.at(\curveA).value  = crvAVal;
        boxes.at(\curveD).value  = crvDVal;
        boxes.at(\curveR).value  = crvRVal
    }

    prSchedOsc {
        oscTask !? { oscTask.stop };
        oscTask = { 0.04.wait; this.prSendOsc }.fork(AppClock)
    }

    prSendOsc {
        var pre = propPrefix;
        instrProxy !? {
            instrProxy.set(
                (pre ++ "atk").asSymbol,      atkVal,
                (pre ++ "dec").asSymbol,       decVal,
                (pre ++ "suslevel").asSymbol,  susVal,
                (pre ++ "rel").asSymbol,       relVal,
                (pre ++ "atkcurve").asSymbol,  crvAVal,
                (pre ++ "deccurve").asSymbol,  crvDVal,
                (pre ++ "relcurve").asSymbol,  crvRVal
            )
        }
    }

    setValues { |vals|
        vals.keysValuesDo { |k, v| this.prSet(k, v) };
        this.prSyncBoxes;
        canvas.refresh;
        this.prSchedOsc
    }

    env {
        ^Env([0, 1, susVal, 0], [atkVal, decVal, relVal], [crvAVal, crvDVal, crvRVal])
    }

    state {
        ^(attack: atkVal, decay: decVal, sustain: susVal, release: relVal,
          curveA: crvAVal, curveD: crvDVal, curveR: crvRVal)
    }
}
