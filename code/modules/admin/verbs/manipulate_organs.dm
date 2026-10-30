/client/proc/manipulate_organs(mob/living/carbon/C in world)
	set name = "Manipulate Organs"
	set category = "Debug"
	var/operation = input("Wybierz operację na organach.", "Manipulacja organami", "anuluj") as null|anything in list("dodaj organ", "dodaj implant", "upuść organ/implant", "usuń organ/implant", "anuluj")
	if (!operation)
		return

	var/list/organs = list()
	switch(operation)
		if("dodaj organ")
			for(var/path in subtypesof(/obj/item/organ))
				var/dat = replacetext("[path]", "/obj/item/organ/", ":")
				organs[dat] = path

			var/obj/item/organ/organ = input("Wybierz typ organu:", "Manipulacja organami", null) as null|anything in organs
			if(!organ)
				return
			organ = organs[organ]
			organ = new organ
			organ.Insert(C)
			log_admin("[key_name(usr)] has added organ [organ.type] to [key_name(C)]")
			message_admins("[key_name_admin(usr)] dodaje organ [organ.type] do [ADMIN_LOOKUPFLW(C)]")

		if("dodaj implant")
			for(var/path in subtypesof(/obj/item/implant))
				var/dat = replacetext("[path]", "/obj/item/implant/", ":")
				organs[dat] = path

			var/obj/item/implant/organ = input("Wybierz typ implantu:", "Manipulacja organami", null) as null|anything in organs
			if(!organ)
				return
			organ = organs[organ]
			organ = new organ
			organ.implant(C)
			log_admin("[key_name(usr)] has added implant [organ.type] to [key_name(C)]")
			message_admins("[key_name_admin(usr)] dodaje implant [organ.type] do [ADMIN_LOOKUPFLW(C)]")

		if("upuść organ/implant", "usuń organ/implant")
			for(var/X in C.internal_organs)
				var/obj/item/organ/I = X
				organs["[I.name] ([I.type])"] = I

			for(var/X in C.implants)
				var/obj/item/implant/I = X
				organs["[I.name] ([I.type])"] = I

			var/obj/item/organ = input("Wybierz organ/implant:", "Manipulacja organami", null) as null|anything in organs
			if(!organ)
				return
			organ = organs[organ]
			if(!organ)
				return
			var/obj/item/organ/O
			var/obj/item/implant/I

			log_admin("[key_name(usr)] has removed [organ.type] from [key_name(C)]")
			message_admins("[key_name_admin(usr)] usuwa [organ.type] z [ADMIN_LOOKUPFLW(C)]")

			if(isorgan(organ))
				O = organ
				O.Remove(C)
			else
				I = organ
				I.removed(C)

			organ.forceMove(get_turf(C))

			if(operation == "usuń organ/implant")
				qdel(organ)
			else if(I) // Put the implant in case.
				var/obj/item/implantcase/case = new(get_turf(C))
				case.imp = I
				I.forceMove(case)
				case.update_icon()
