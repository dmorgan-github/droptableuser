(
Require(App.librarydir ++ "ui/common.scd");
Fdef(\wave, {|buf|

    var wavecolors = [
        Color(0.78598186969757, 0.75455839633942, 0.59287083148956),
        Color(0.34656608104706, 0.33435337543488, 0.45881831645966)
    ];
    var gridcolor = Color.rand;
    var numChannels = buf.numChannels;
    var sfv = SoundFileView()
    .background_(Color.rand.alpha_(0.3))
    .gridOn_(true)
    .drawsRMS_(false)
    .rmsColor_(Color.rand)
    .timeCursorOn_(false)
    .gridResolution_(0.0)
    .waveColors_( wavecolors )
    .gridColor_(gridcolor);

    var view = View().layout_(VLayout(sfv))
    .palette_(QPalette.dark)
    .minSize_(Size(200, 200));

    buf.loadToFloatArray(action:{|a|
        {
            //var start = startPos * numframes;
            //var end = (endPos * numframes) - start;
            sfv.setData(a, channels: numChannels);
            sfv.setSelection (0, [0, 0]);
        }.defer
    });

    view.front
});
)