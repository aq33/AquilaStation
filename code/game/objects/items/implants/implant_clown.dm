/obj/item/implant/sad_trombone
	name = "implant smutnego puzonu"
	activated = 0

/obj/item/implant/sad_trombone/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Implant smutnego puzonu Honk Co.<BR><b>Żywotność:</b> aktywuje się po śmierci.<BR>
				"}
	return dat

/obj/item/implant/sad_trombone/trigger(emote, mob/source)
	if(emote == "deathgasp")
		playsound(loc, 'sound/misc/sadtrombone.ogg', 50, 0)

/obj/item/implanter/sad_trombone
	name = "implanter (smutny puzon)"
	imp_type = /obj/item/implant/sad_trombone

/obj/item/implantcase/sad_trombone
	name = "etui na implant – „Smutny puzon”"
	desc = "Szklane etui z implantem smutnego puzonu."
	imp_type = /obj/item/implant/sad_trombone
