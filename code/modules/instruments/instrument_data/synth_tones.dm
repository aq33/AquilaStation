/datum/instrument/tones
	name = "Idealny ton"
	category = "Tony"
	abstract_type = /datum/instrument/tones

/datum/instrument/tones/square_wave
	name = "Idealna fala prostokątna"
	id = "square"
	real_samples = list("81"='sound/instruments/synthesis_samples/tones/Square.ogg')

/datum/instrument/tones/sine_wave
	name = "Idealna fala sinusoidalna"
	id = "sine"
	real_samples = list("81"='sound/instruments/synthesis_samples/tones/Sine.ogg')

/datum/instrument/tones/saw_wave
	name = "Idealna fala piłokształtna"
	id = "saw"
	real_samples = list("81"='sound/instruments/synthesis_samples/tones/Sawtooth.ogg')
