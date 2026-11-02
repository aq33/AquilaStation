/client/proc/atmosscan()
	set category = "Mapping"
	set name = "Check Plumbing"
	if(!src.holder)
		to_chat(src, "Tylko administratorzy mogą używać tej komendy.")
		return
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Plumbing") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	//all plumbing - yes, some things might get stated twice, doesn't matter.
	for(var/obj/machinery/atmospherics/components/pipe in GLOB.machines)
		if(pipe.z && (!pipe.nodes || !pipe.nodes.len || (null in pipe.nodes)))
			to_chat(usr, "Niepodłączona rura ([pipe.name]) w: [ADMIN_VERBOSEJMP(pipe)]")

	//Manifolds
	for(var/obj/machinery/atmospherics/pipe/manifold/pipe in GLOB.machines)
		if(pipe.z && (!pipe.nodes || !pipe.nodes.len || (null in pipe.nodes)))
			to_chat(usr, "Niepodłączona rura ([pipe.name]) w: [ADMIN_VERBOSEJMP(pipe)]")

	//Pipes
	for(var/obj/machinery/atmospherics/pipe/simple/pipe in GLOB.machines)
		if(pipe.z && (!pipe.nodes || !pipe.nodes.len || (null in pipe.nodes)))
			to_chat(usr, "Niepodłączona rura ([pipe.name]) w: [ADMIN_VERBOSEJMP(pipe)]")

	//Erroneous Connections, e.g. duplicate pipes
	//This uses pipeline_expansion(), so you can detect some atmos machineries causing problems at pipenet code.
	for (var/obj/machinery/atmospherics/AM in GLOB.machines)
		for (var/obj/machinery/atmospherics/AMT in AM.pipeline_expansion())
			if (!(AM in AMT.pipeline_expansion()))
				to_chat(usr, "Błędne połączenia wokół: [AM.name]. Podejrzenie zdublowanych lub zbłąkanych rur w okolicy: [ADMIN_VERBOSEJMP(AM)]")

/client/proc/powerdebug()
	set category = "Mapping"
	set name = "Check Power"
	if(!src.holder)
		to_chat(src, "Tylko administratorzy mogą używać tej komendy.")
		return
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Power") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	for (var/datum/powernet/PN in SSmachines.powernets)
		if (!PN.nodes || !PN.nodes.len)
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(usr, "Sieć energetyczna bez węzłów! (numer [PN.number]) - przykładowy kabel w: [ADMIN_VERBOSEJMP(C)]")

		if (!PN.cables || (PN.cables.len < 10))
			if(PN.cables && (PN.cables.len > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(usr, "Sieć energetyczna z mniej niż 10 kablami! (numer [PN.number]) - przykładowy kabel w: [ADMIN_VERBOSEJMP(C)]")
