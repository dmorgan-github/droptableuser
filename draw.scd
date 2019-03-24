(
var win = Window.new.front;
win.view.background_(Color.white);
win.drawFunc = {
    Pen.translate(200, 200);
    50.do{
        // set the Color
        Pen.color = Color.black(rrand(0.0, 1), rrand(0.0, 0.5));
        Pen.addArc((200.rand)@(200.rand), rrand(10, 200), 2pi.rand, pi);
        //Pen.perform([\stroke, \fill].choose);
		Pen.perform([\stroke].choose);
    }
};
win.refresh;
)


(
var c1 = Color(0.58719735145569, 0.52956941127777, 0.62756681442261);
var c2 = Color(0.75625841617584, 0.50563073158264, 0.43229427337646);
w = Window.new(bounds:800@800).front;
w.drawFunc = {
    // fill the gradient
    Pen.addRect(w.view.bounds.insetBy(30));
    Pen.fillAxialGradient(w.view.bounds.leftTop, w.view.bounds.rightBottom, c1, c2);
};
w.refresh;

StaticText(w, Rect(50, -30, 400, 200)).string_("drop_table_user").font_(Font().size_(32));
StaticText(w, Rect(665, -30, 200, 200)).string_("undo").font_(Font().size_(32));

)

