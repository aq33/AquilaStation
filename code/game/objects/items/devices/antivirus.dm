/obj/item/disk/antivirus
	name = "NTOS defender"
	desc = "Domyślny antywirus wszystkich systemów Nanotrasen. Wystarczy go podłączyć i patrzeć, jak nie działa."
	var/resistcap = 6 //one higher than what it can cure
	icon_state = "antivirus4"

/obj/item/disk/antivirus/attack(mob/M, mob/user, def_zone)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/cured = 0
		if(MOB_ROBOTIC in H.mob_biotypes)
			H.say("Instalowanie [src]. Nie wyłączaj ani nie przeszkadzaj jednostce [H.dna.species] podczas instalacji", forced = "antivirus")
			if(do_mob(user, H, 450)) //it has unlimited uses, but that's balanced by being very slow
				H.say("[src] zainstalowany pomyślnie. Rozpoczynanie skanowania.", forced = "antivirus")
				for(var/thing in H.diseases)
					var/datum/disease/D = thing
					if(istype(D, /datum/disease/advance))
						var/datum/disease/advance/A = D
						if(A.resistance >= resistcap)
							if(A.stealth <= 4)
								H.say("Nie udało się usunąć [D].exe", forced = "antivirus")
							continue
					else if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
						H.say("Nie udało się usunąć [D].exe", forced = "antivirus")
						continue
					cured += 1
					H.say("Usunięto [D].exe...", forced = "antivirus")
					D.cure(TRUE)
					stoplag(5 - cured)
				if(cured)
					H.say("Usunięto złośliwych plików: [cured]. Dziękujemy za korzystanie z [src].", forced = "antivirus")
				else
					H.say("Nie wykryto złośliwych plików!", forced = "antivirus")
			return
		else
			return ..()


/obj/item/disk/antivirus/tier2
	name = "Ahoy"
	desc = "Darmowy antywirus, który radzi sobie z większością pospolitego złośliwego oprogramowania, ale przepuszcza większość dobrze napisanych wirusów."
	resistcap = 11
	icon_state = "antivirus1"

/obj/item/disk/antivirus/tier3
	name = "McValozk"
	desc = "Solidny antywirus na większość potrzeb, znany głównie z powiązań z osławionym emigrantem, od którego marka się potem odcięła."
	resistcap = 16
	icon_state = "antivirus3"

/obj/item/disk/antivirus/tier4
	name = "Nano-Ton"
	desc = "Drogi, niestandardowy antywirus, którego używają głównie grube ryby mające coś do ukrycia."
	resistcap = INFINITY
	icon_state = "antivirus2"
