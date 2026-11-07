world
	maxx = 20
	maxy = 20
	maxz = 1
	mob = /mob/tester
	fps = 20

/turf
	icon = 'dot.png'
	color = "#202020"

/mob/tester
	icon = 'dot.png'
	color = "#00ff00"

/mob/tester/Login()
	..()
	loc = locate(10, 10, 1)
	world.log << "[world.timeofday] login"
	src << browse_rsc('noise.ogg', "noise.ogg")
	src << browse_rsc('tone2k.ogg', "tone2k.ogg")
	src << browse_rsc('tone9k.ogg', "tone9k.ogg")
	src << browse(file2text('wa.html'), "window=wa;size=360x80")
	spawn(30)
		run_tests()

/mob/tester/Topic(href, list/href_list)
	if(href_list["walog"])
		world.log << "[world.timeofday] JS: [href_list["walog"]]"
		return
	..()

/mob/tester/proc/web(list/p)
	src << output(list2params(list(json_encode(p))), "wa.browser:play")

/mob/tester/proc/mark(label)
	world.log << "[world.timeofday] [label]"

/mob/tester/proc/run_tests()
	src << output(list2params(list("\ref[src]")), "wa.browser:init")
	for(var/f in list("noise.ogg", "tone2k.ogg", "tone9k.ogg"))
		src << output(list2params(list(f)), "wa.browser:load")
	sleep(30)
	// opóźnienie: ten sam tick, natywny 2 kHz i Web Audio 9 kHz
	for(var/i in 1 to 5)
		mark("L[i] latency")
		src << sound('tone2k.ogg', volume = 15)
		web(list("id" = "L[i]", "f" = "tone9k.ogg", "v" = 15))
		sleep(20)
	mark("W0 plain"); web(list("id" = "W0", "f" = "noise.ogg")); sleep(20)
	mark("W1 lp800"); web(list("id" = "W1", "f" = "noise.ogg", "lp" = 800)); sleep(20)
	mark("W2 lp300"); web(list("id" = "W2", "f" = "noise.ogg", "lp" = 300)); sleep(20)
	mark("W3 hrtf right"); web(list("id" = "W3", "f" = "noise.ogg", "pan" = 1, "hrtf" = 1, "x" = 3, "z" = 0)); sleep(20)
	mark("W4 equalpower right"); web(list("id" = "W4", "f" = "noise.ogg", "pan" = 1, "hrtf" = 0, "x" = 3, "z" = 0)); sleep(20)
	mark("W5 hrtf front"); web(list("id" = "W5", "f" = "noise.ogg", "pan" = 1, "hrtf" = 1, "x" = 0, "z" = -3)); sleep(20)
	mark("W6 hrtf behind"); web(list("id" = "W6", "f" = "noise.ogg", "pan" = 1, "hrtf" = 1, "x" = 0, "z" = 3)); sleep(20)
	mark("W7 reverb"); web(list("id" = "W7", "f" = "noise.ogg", "rev" = 0.6)); sleep(30)
	winset(src, "wa", "is-visible=false")
	sleep(10)
	mark("W8 hidden plain"); web(list("id" = "W8", "f" = "noise.ogg")); sleep(20)
	// koszt CPU: po 20 s spokoju, natywnie i przez Web Audio, 20 dźwięków/s
	mark("idle start"); sleep(200); mark("idle end")
	mark("native start")
	for(var/t in 1 to 200)
		src << sound('noise.ogg', volume = 3, channel = 0)
		if(t % 2)
			src << sound('tone2k.ogg', volume = 3, channel = 0)
		sleep(1)
	mark("native end")
	mark("web start")
	for(var/t in 1 to 200)
		web(list("id" = "c", "f" = "noise.ogg", "v" = 3, "lp" = 1200, "pan" = 1, "hrtf" = 1, "x" = rand(-5, 5), "z" = rand(-5, 5), "quiet" = 1))
		if(t % 2)
			web(list("id" = "c", "f" = "tone2k.ogg", "v" = 3, "lp" = 1200, "pan" = 1, "hrtf" = 1, "x" = rand(-5, 5), "z" = rand(-5, 5), "quiet" = 1))
		sleep(1)
	mark("web end")
	mark("webrev start")
	for(var/t in 1 to 200)
		web(list("id" = "c", "f" = "noise.ogg", "v" = 3, "lp" = 1200, "pan" = 1, "hrtf" = 1, "x" = rand(-5, 5), "z" = rand(-5, 5), "rev" = 0.3, "quiet" = 1))
		if(t % 2)
			web(list("id" = "c", "f" = "tone2k.ogg", "v" = 3, "lp" = 1200, "pan" = 1, "hrtf" = 1, "x" = rand(-5, 5), "z" = rand(-5, 5), "rev" = 0.3, "quiet" = 1))
		sleep(1)
	mark("webrev end")
	sleep(20)
	mark("END")
	shutdown()
