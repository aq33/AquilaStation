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
	mark("W9 bus reverb"); web(list("id" = "W9", "f" = "noise.ogg", "bus" = 0.6)); sleep(30)
	// koszt CPU: po 20 s spokoju, natywnie i przez Web Audio, 20 dźwięków/s
	mark("idle start"); sleep(200); mark("idle end")
	mark("web start")
	for(var/t in 1 to 200)
		web(list("id" = "c", "f" = "noise.ogg", "v" = 3, "lp" = 1200, "pan" = 1, "hrtf" = 1, "x" = rand(-5, 5), "z" = rand(-5, 5), "quiet" = 1))
		if(t % 2)
			web(list("id" = "c", "f" = "tone2k.ogg", "v" = 3, "lp" = 1200, "pan" = 1, "hrtf" = 1, "x" = rand(-5, 5), "z" = rand(-5, 5), "quiet" = 1))
		sleep(1)
	mark("web end")
	mark("webbus start")
	for(var/t in 1 to 200)
		web(list("id" = "c", "f" = "noise.ogg", "v" = 3, "lp" = 1200, "pan" = 1, "hrtf" = 1, "x" = rand(-5, 5), "z" = rand(-5, 5), "bus" = 0.3, "quiet" = 1))
		if(t % 2)
			web(list("id" = "c", "f" = "tone2k.ogg", "v" = 3, "lp" = 1200, "pan" = 1, "hrtf" = 1, "x" = rand(-5, 5), "z" = rand(-5, 5), "bus" = 0.3, "quiet" = 1))
		sleep(1)
	mark("webbus end")
	sleep(20)
	mark("END")
	shutdown()
