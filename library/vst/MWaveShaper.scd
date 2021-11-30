(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Asymmetric', 'mwaveshaper_asymmetric'.kr(0.0),
			'Automatic gain control', 'mwaveshaper_automaticgaincontro'.kr(0.0),
			'DC blocker', 'mwaveshaper_dcblocker'.kr(0.0),
			'Dry/Wet', 'mwaveshaper_drywet'.kr(0.5),
			'Input gain', 'mwaveshaper_inputgain'.kr(0.5),
			'Mode', 'mwaveshaper_mode'.kr(0.0),
			'Output gain', 'mwaveshaper_outputgain'.kr(0.5),
			'Point 1 X (Shape)', 'mwaveshaper_point1xshape'.kr(0.0),
			'Point 1 Y (Shape)', 'mwaveshaper_point1yshape'.kr(0.0),
			'Point 2 X (Shape)', 'mwaveshaper_point2xshape'.kr(1.0),
			'Point 2 Y (Shape)', 'mwaveshaper_point2yshape'.kr(1.0),
			'Point 3 X (Shape)', 'mwaveshaper_point3xshape'.kr(0.0),
			'Point 3 Y (Shape)', 'mwaveshaper_point3yshape'.kr(0.0),
			'Point 4 X (Shape)', 'mwaveshaper_point4xshape'.kr(0.0),
			'Point 4 Y (Shape)', 'mwaveshaper_point4yshape'.kr(0.0),
			'Point 5 X (Shape)', 'mwaveshaper_point5xshape'.kr(0.0),
			'Point 5 Y (Shape)', 'mwaveshaper_point5yshape'.kr(0.0),
			'Point1Curvature(Shape)', 'mwaveshaper_point1curvatureshap'.kr(0.5),
			'Point1Smoothness(Shape)', 'mwaveshaper_point1smoothnesssha'.kr(0.0),
			'Point2Curvature(Shape)', 'mwaveshaper_point2curvatureshap'.kr(0.5),
			'Point2Smoothness(Shape)', 'mwaveshaper_point2smoothnesssha'.kr(0.0),
			'Point3Curvature(Shape)', 'mwaveshaper_point3curvatureshap'.kr(0.0),
			'Point3Smoothness(Shape)', 'mwaveshaper_point3smoothnesssha'.kr(0.0),
			'Point4Curvature(Shape)', 'mwaveshaper_point4curvatureshap'.kr(0.0),
			'Point4Smoothness(Shape)', 'mwaveshaper_point4smoothnesssha'.kr(0.0),
			'Point5Curvature(Shape)', 'mwaveshaper_point5curvatureshap'.kr(0.0),
			'Point5Smoothness(Shape)', 'mwaveshaper_point5smoothnesssha'.kr(0.0),
			'Previous(PresetTrigger)', 'mwaveshaper_previouspresettrigg'.kr(0.0),
			//'next (Preset trigger)', 'mwaveshaper_nextpresettrigger'.kr(0.0),
		],
		info:'MWaveShaper'
    )
}
)