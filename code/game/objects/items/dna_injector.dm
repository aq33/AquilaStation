/obj/item/dnainjector
	name = "\improper iniektor DNA"
	desc = "Tani jednorazowy autoinjektor, który wprowadza użytkownikowi DNA."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "dnainjector"
	base_icon_state = "dnainjector"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY

	var/damage_coeff  = 1
	var/list/fields
	var/list/add_mutations = list()
	var/list/remove_mutations = list()

	var/used = FALSE

/obj/item/dnainjector/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/dnainjector/proc/inject(mob/living/carbon/M, mob/user)
	if(M.has_dna() && !HAS_TRAIT(M, TRAIT_RADIMMUNE) && !HAS_TRAIT(M, TRAIT_BADDNA))
		M.radiation += rand(20/(damage_coeff  ** 2),50/(damage_coeff  ** 2))
		var/log_msg = "[key_name(user)] injected [key_name(M)] with the [name]"
		for(var/HM in remove_mutations)
			M.dna.remove_mutation(HM)
		if(length(remove_mutations))
			log_msg += " (usuwane mutacje: [english_list(remove_mutations)])"
		for(var/HM in add_mutations)
			if(HM == RACEMUT)
				message_admins("[ADMIN_LOOKUPFLW(user)] wstrzykuje [key_name_admin(M)]: [name] <span class='danger'>(MAŁPA)</span>")
				log_msg += " (MONKEY)"
			if(M.dna.mutation_in_sequence(HM))
				M.dna.activate_mutation(HM)
			else
				M.dna.add_mutation(HM, MUT_EXTRA)
		if(fields)
			if(fields["name"] && fields["UE"] && fields["blood_type"])
				M.real_name = fields["name"]
				M.dna.unique_enzymes = fields["UE"]
				M.name = M.real_name
				M.dna.blood_type = fields["blood_type"]
			if(fields["UI"])	//UI+UE
				M.dna.uni_identity = merge_text(M.dna.uni_identity, fields["UI"])
				M.updateappearance(mutations_overlay_update=1)
		log_attack("[log_msg] [loc_name(user)]")
		return TRUE
	return FALSE

/obj/item/dnainjector/attack(mob/living/target, mob/living/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>Brakuje ci zręczności, by to zrobić!</span>")
		return
	if(used)
		to_chat(user, "<span class='warning'>Ten iniektor jest zużyty!</span>")
		return
	if(!target.can_inject(user, TRUE))
		return
	log_combat(user, target, "attempted to inject", src)

	if(target != user)
		target.visible_message("<span class='danger'>[user] próbuje wstrzyknąć [target] [src]!</span>", \
			"<span class='userdanger'>[user] próbuje wstrzyknąć ci [src]!</span>")
		if(!do_mob(user, target) || used)
			return
		target.visible_message("<span class='danger'>[user] wstrzykuje [target] zawartość [src]!", \
						"<span class='userdanger'>[user] wstrzykuje ci zawartość [src]!</span>")

	else
		to_chat(user, "<span class='notice'>Wstrzykujesz sobie [src].</span>")

	log_combat(user, target, "injected", src)

	if(!inject(target, user))	//Now we actually do the heavy lifting.
		to_chat(user, "<span class='notice'>Wygląda na to, że [target] nie ma kompatybilnego DNA.</span>")

	used = TRUE
	icon_state = "[base_icon_state]0"
	desc += " Ten jest zużyty, lepiej go zutylizuj!"


/obj/item/dnainjector/antihulk
	name = "\improper iniektor DNA (anty-Hulk)"
	desc = "Leczy zieloną skórę."
	remove_mutations = list(HULK)

/obj/item/dnainjector/hulkmut
	name = "\improper iniektor DNA (Hulk)"
	desc = "Zrobi z ciebie wielkiego siłacza, ale zepsuje ci cerę."
	add_mutations = list(HULK)

/obj/item/dnainjector/xraymut
	name = "\improper iniektor DNA (Wzrok rentgenowski)"
	desc = "Wreszcie zobaczysz, co porabia Kapitan."
	add_mutations = list(XRAY)

/obj/item/dnainjector/antixray
	name = "\improper iniektor DNA (anty-Wzrok rentgenowski)"
	desc = "Sprawi, że będziesz widzieć mocniej."
	remove_mutations = list(XRAY)

/////////////////////////////////////
/obj/item/dnainjector/antiglasses
	name = "\improper iniektor DNA (anty-Krótkowzroczność)"
	desc = "Wyrzuć te okulary!"
	remove_mutations = list(BADSIGHT)

/obj/item/dnainjector/glassesmut
	name = "\improper iniektor DNA (Krótkowzroczność)"
	desc = "Sprawi, że będziesz potrzebować frajerskich okularów."
	add_mutations = list(BADSIGHT)

/obj/item/dnainjector/epimut
	name = "\improper iniektor DNA (Epilepsja)"
	desc = "Trzęś, trzęś, trzęś całym pokojem!"
	add_mutations = list(EPILEPSY)

/obj/item/dnainjector/antiepi
	name = "\improper iniektor DNA (anty-Epilepsja)"
	desc = "Wyleczy cię z trzęsienia pokojem."
	remove_mutations = list(EPILEPSY)
////////////////////////////////////
/obj/item/dnainjector/anticough
	name = "\improper iniektor DNA (anty-Kaszel)"
	desc = "Zatrzyma ten okropny hałas."
	remove_mutations = list(COUGH)

/obj/item/dnainjector/coughmut
	name = "\improper iniektor DNA (Kaszel)"
	desc = "Wydobędzie z twojego gardła przerażający dźwięk."
	add_mutations = list(COUGH)

/obj/item/dnainjector/antidwarf
	name = "\improper iniektor DNA (anty-Karłowatość)"
	desc = "Pomoże ci wyrosnąć na dużego i silnego."
	remove_mutations = list(DWARFISM)

/obj/item/dnainjector/dwarf
	name = "\improper iniektor DNA (Karłowatość)"
	desc = "Mały jest ten świat."
	add_mutations = list(DWARFISM)

/obj/item/dnainjector/clumsymut
	name = "\improper iniektor DNA (Niezdarność)"
	desc = "Tworzy klaunich popleczników."
	add_mutations = list(CLOWNMUT)

/obj/item/dnainjector/anticlumsy
	name = "\improper iniektor DNA (anty-Niezdarność)"
	desc = "Zastosuj na Klaunie z Policji."
	remove_mutations = list(CLOWNMUT)

/obj/item/dnainjector/cluwnemut
	name = "\improper iniektor DNA (Kluwnifikacja)"
	desc = "To twoja ostatnia szansa, by zawrócić."
	add_mutations = list(CLOWNMUT)

/obj/item/dnainjector/anticluwne
	name = "\improper iniektor DNA (anty-Kluwn)"
	desc = "To nie zadziała."
	remove_mutations = list(CLOWNMUT)

/obj/item/dnainjector/antitour
	name = "\improper iniektor DNA (anty-Zespół Tourette'a)"
	desc = "Wyleczy zespół Tourette'a."
	remove_mutations = list(TOURETTES)

/obj/item/dnainjector/tourmut
	name = "\improper iniektor DNA (Zespół Tourette'a)"
	desc = "Daje ci paskudny przypadek zespołu Tourette'a."
	add_mutations = list(TOURETTES)

/obj/item/dnainjector/stuttmut
	name = "\improper iniektor DNA (Nerwowość)"
	desc = "Sprawi, że będziesz się j-j-jąkaćććć."
	add_mutations = list(NERVOUS)

/obj/item/dnainjector/antistutt
	name = "\improper iniektor DNA (anty-Nerwowość)"
	desc = "Naprawia tę wadę wymowy."
	remove_mutations = list(NERVOUS)

/obj/item/dnainjector/antifire
	name = "\improper iniektor DNA (anty-Adaptacja kosmiczna)"
	desc = "Leczy ogień."
	remove_mutations = list(SPACEMUT)

/obj/item/dnainjector/firemut
	name = "\improper iniektor DNA (Adaptacja kosmiczna)"
	desc = "Daje ci ogień."
	add_mutations = list(SPACEMUT)

/obj/item/dnainjector/blindmut
	name = "\improper iniektor DNA (Ślepota)"
	desc = "Sprawia, że nic nie widzisz."
	add_mutations = list(BLINDMUT)

/obj/item/dnainjector/antiblind
	name = "\improper iniektor DNA (anty-Ślepota)"
	desc = "TO CUD!!!"
	remove_mutations = list(BLINDMUT)

/obj/item/dnainjector/antitele
	name = "\improper iniektor DNA (anty-Telekineza)"
	desc = "Sprawi, że nie będziesz umieć sterować umysłem."
	remove_mutations = list(TK)

/obj/item/dnainjector/telemut
	name = "\improper iniektor DNA (Telekineza)"
	desc = "Supermózgowiec!"
	add_mutations = list(TK)

/obj/item/dnainjector/telemut/darkbundle
	name = "\improper iniektor DNA"
	desc = "Dobrze. Pozwól, by nienawiść przez ciebie płynęła."

/obj/item/dnainjector/deafmut
	name = "\improper iniektor DNA (Głuchota)"
	desc = "Przepraszam, co mówiłeś?"
	add_mutations = list(DEAFMUT)

/obj/item/dnainjector/antideaf
	name = "\improper iniektor DNA (anty-Głuchota)"
	desc = "Sprawi, że znów będziesz słyszeć."
	remove_mutations = list(DEAFMUT)

/obj/item/dnainjector/h2m
	name = "\improper iniektor DNA (Człowiek > Małpa)"
	desc = "Zrobi z ciebie pchlarza."
	add_mutations = list(RACEMUT)

/obj/item/dnainjector/m2h
	name = "\improper iniektor DNA (Małpa > Człowiek)"
	desc = "Sprawi, że będziesz... mniej owłosiony."
	remove_mutations = list(RACEMUT)

/obj/item/dnainjector/antichameleon
	name = "\improper iniektor DNA (anty-Kameleon)"
	remove_mutations = list(CHAMELEON)

/obj/item/dnainjector/chameleonmut
	name = "\improper iniektor DNA (Kameleon)"
	add_mutations = list(CHAMELEON)

/obj/item/dnainjector/antiwacky
	name = "\improper iniektor DNA (anty-Zwariowany głos)"
	remove_mutations = list(WACKY)

/obj/item/dnainjector/wackymut
	name = "\improper iniektor DNA (Zwariowany głos)"
	add_mutations = list(WACKY)

/obj/item/dnainjector/antimute
	name = "\improper iniektor DNA (anty-Niemota)"
	remove_mutations = list(MUT_MUTE)

/obj/item/dnainjector/mutemut
	name = "\improper iniektor DNA (Niemota)"
	add_mutations = list(MUT_MUTE)

/obj/item/dnainjector/antismile
	name = "\improper iniektor DNA (anty-Uśmiech)"
	remove_mutations = list(SMILE)

/obj/item/dnainjector/smilemut
	name = "\improper iniektor DNA (Uśmiech)"
	add_mutations = list(SMILE)

/obj/item/dnainjector/unintelligiblemut
	name = "\improper iniektor DNA (Niezrozumiałość)"
	add_mutations = list(UNINTELLIGIBLE)

/obj/item/dnainjector/antiunintelligible
	name = "\improper iniektor DNA (anty-Niezrozumiałość)"
	remove_mutations = list(UNINTELLIGIBLE)

/obj/item/dnainjector/polishmut//AQ EDIT
	name = "\improper iniektor DNA (Polskość)"
	add_mutations = list(POLISH)

/obj/item/dnainjector/antipolish//AQ EDIT
	name = "\improper iniektor DNA (anty-Polskość)"
	remove_mutations = list(POLISH)

/obj/item/dnainjector/chavmut
	name = "\improper iniektor DNA (Dresiarz)"
	add_mutations = list(CHAV)

/obj/item/dnainjector/antichav
	name = "\improper iniektor DNA (anty-Dresiarz)"
	remove_mutations = list(CHAV)

/obj/item/dnainjector/elvismut
	name = "\improper iniektor DNA (Elvis)"
	add_mutations = list(ELVIS)

/obj/item/dnainjector/antielvis
	name = "\improper iniektor DNA (anty-Elvis)"
	remove_mutations = list(ELVIS)

/obj/item/dnainjector/lasereyesmut
	name = "\improper iniektor DNA (Laserowe oczy)"
	add_mutations = list(LASEREYES)

/obj/item/dnainjector/antilasereyes
	name = "\improper iniektor DNA (anty-Laserowe oczy)"
	remove_mutations = list(LASEREYES)

/obj/item/dnainjector/void
	name = "\improper iniektor DNA (Magnes pustki)"
	add_mutations = list(VOID)

/obj/item/dnainjector/antivoid
	name = "\improper iniektor DNA (anty-Magnes pustki)"
	remove_mutations = list(VOID)

/obj/item/dnainjector/antenna
	name = "\improper iniektor DNA (Antena)"
	add_mutations = list(ANTENNA)

/obj/item/dnainjector/antiantenna
	name = "\improper iniektor DNA (anty-Antena)"
	remove_mutations = list(ANTENNA)

/obj/item/dnainjector/paranoia
	name = "\improper iniektor DNA (Paranoja)"
	add_mutations = list(PARANOIA)

/obj/item/dnainjector/antiparanoia
	name = "\improper iniektor DNA (anty-Paranoja)"
	remove_mutations = list(PARANOIA)

/obj/item/dnainjector/radioactive
	name = "\improper iniektor DNA (Radioaktywność)"
	add_mutations = list(RADIOACTIVE)

/obj/item/dnainjector/antiradioactive
	name = "\improper iniektor DNA (anty-Radioaktywność)"
	remove_mutations = list(RADIOACTIVE)
/obj/item/dnainjector/olfaction
	name = "\improper iniektor DNA (Transcendentny węch)"
	add_mutations = list(OLFACTION)

/obj/item/dnainjector/antiolfaction
	name = "\improper iniektor DNA (anty-Transcendentny węch)"
	remove_mutations = list(OLFACTION)

/obj/item/dnainjector/insulated
	name = "\improper iniektor DNA (Izolacja)"
	add_mutations = list(INSULATED)

/obj/item/dnainjector/antiinsulated
	name = "\improper iniektor DNA (anty-Izolacja)"
	remove_mutations = list(INSULATED)

/obj/item/dnainjector/shock
	name = "\improper iniektor DNA (Porażający dotyk)"
	add_mutations = list(SHOCKTOUCH)

/obj/item/dnainjector/antishock
	name = "\improper iniektor DNA (anty-Porażający dotyk)"
	remove_mutations = list(SHOCKTOUCH)

/obj/item/dnainjector/spatialinstability
	name = "\improper iniektor DNA (Niestabilność przestrzenna)"
	add_mutations = list(BADBLINK)

/obj/item/dnainjector/antispatialinstability
	name = "\improper iniektor DNA (anty-Niestabilność przestrzenna)"
	remove_mutations = list(BADBLINK)

/obj/item/dnainjector/acidflesh
	name = "\improper iniektor DNA (Kwasowe ciało)"
	add_mutations = list(ACIDFLESH)

/obj/item/dnainjector/antiacidflesh
	name = "\improper iniektor DNA (Kwasowe ciało)"
	remove_mutations = list(ACIDFLESH)

/obj/item/dnainjector/gigantism
	name = "\improper iniektor DNA (Gigantyzm)"
	add_mutations = list(GIGANTISM)

/obj/item/dnainjector/antigigantism
	name = "\improper iniektor DNA (anty-Gigantyzm)"
	remove_mutations = list(GIGANTISM)

/obj/item/dnainjector/spastic
	name = "\improper iniektor DNA (Spastyczność)"
	add_mutations = list(SPASTIC)

/obj/item/dnainjector/antispastic
	name = "\improper iniektor DNA (anty-Spastyczność)"
	remove_mutations = list(SPASTIC)

/obj/item/dnainjector/twoleftfeet
	name = "\improper iniektor DNA (Dwie lewe nogi)"
	add_mutations = list(EXTRASTUN)

/obj/item/dnainjector/antitwoleftfeet
	name = "\improper iniektor DNA (anty-Dwie lewe nogi)"
	remove_mutations = list(EXTRASTUN)

/obj/item/dnainjector/geladikinesis
	name = "\improper iniektor DNA (Geladykineza)"
	add_mutations = list(GELADIKINESIS)

/obj/item/dnainjector/antigeladikinesis
	name = "\improper iniektor DNA (anty-Geladykineza)"
	remove_mutations = list(GELADIKINESIS)

/obj/item/dnainjector/cryokinesis
	name = "\improper iniektor DNA (Kriokineza)"
	add_mutations = list(CRYOKINESIS)

/obj/item/dnainjector/anticryokinesis
	name = "\improper iniektor DNA (anty-Kriokineza)"
	remove_mutations = list(CRYOKINESIS)

/obj/item/dnainjector/thermal
	name = "\improper iniektor DNA (Widzenie termiczne)"
	add_mutations = list(THERMAL)

/obj/item/dnainjector/antithermal
	name = "\improper iniektor DNA (anty-Widzenie termiczne)"
	remove_mutations = list(THERMAL)

/obj/item/dnainjector/glow
	name = "\improper iniektor DNA (Świecenie)"
	add_mutations = list(GLOWY)

/obj/item/dnainjector/removeglow
	name = "\improper iniektor DNA (anty-Świecenie)"
	remove_mutations = list(GLOWY)

/obj/item/dnainjector/antiglow
	name = "\improper iniektor DNA (Antyświecenie)"
	add_mutations = list(ANTIGLOWY)

/obj/item/dnainjector/removeantiglow
	name = "\improper iniektor DNA (anty-Antyświecenie)"
	remove_mutations = list(ANTIGLOWY)

/obj/item/dnainjector/strongwings
	name = "\improper iniektor DNA (Wzmocnione skrzydła)"
	add_mutations = list(STRONGWINGS)

/obj/item/dnainjector/antistrongwings
	name = "\improper iniektor DNA (anty-Wzmocnione skrzydła)"
	remove_mutations = list(STRONGWINGS)

/obj/item/dnainjector/catclaws
	name = "\improper iniektor DNA (Kocie pazury)"
	add_mutations = list(CATCLAWS)

/obj/item/dnainjector/anticatclaws
	name = "\improper iniektor DNA (anty-Kocie pazury)"
	remove_mutations = list(CATCLAWS)

/obj/item/dnainjector/overload
	name = "\improper iniektor DNA (Przeciążenie)"
	add_mutations = list(OVERLOAD)

/obj/item/dnainjector/antioverload
	name = "\improper iniektor DNA (anty-Przeciążenie)"
	remove_mutations = list(OVERLOAD)

/obj/item/dnainjector/acidooze
	name = "\improper iniektor DNA (Kwasowe dłonie)"
	add_mutations = list(ACIDOOZE)

/obj/item/dnainjector/antiacidooze
	name = "\improper iniektor DNA (Pepto-Bismol)"
	remove_mutations = list(ACIDOOZE)

/obj/item/dnainjector/medievalmut
	name = "\improper iniektor DNA (Średniowiecze)"
	add_mutations = list(MEDIEVAL)

/obj/item/dnainjector/antimedieval
	name = "\improper iniektor DNA (anty-Średniowiecze)"
	remove_mutations = list(MEDIEVAL)

/obj/item/dnainjector/timed
	var/duration = 600

/obj/item/dnainjector/timed/inject(mob/living/carbon/M, mob/user)
	if(M.stat == DEAD)	//prevents dead people from having their DNA changed
		to_chat(user, "<span class='notice'>Nie możesz modyfikować DNA [M], gdy nie żyje.</span>")
		return FALSE

	if(M.has_dna() && !(HAS_TRAIT(M, TRAIT_BADDNA)))
		M.radiation += rand(20/(damage_coeff  ** 2),50/(damage_coeff  ** 2))
		var/log_msg = "[key_name(user)] injected [key_name(M)] with the [name]"
		var/endtime = world.time+duration
		for(var/mutation in remove_mutations)
			if(mutation == RACEMUT)
				if(ishuman(M))
					continue
				M = M.dna.remove_mutation(mutation)
			else
				M.dna.remove_mutation(mutation)
		for(var/mutation in add_mutations)
			if(M.dna.get_mutation(mutation))
				continue //Skip permanent mutations we already have.
			if(mutation == RACEMUT && ishuman(M))
				message_admins("[ADMIN_LOOKUPFLW(user)] wstrzykuje [key_name_admin(M)]: [name] <span class='danger'>(MAŁPA)</span>")
				log_msg += " (MONKEY)"
				M = M.dna.add_mutation(mutation, MUT_OTHER, endtime)
			else
				M.dna.add_mutation(mutation, MUT_OTHER, endtime)
		if(fields)
			if(fields["name"] && fields["UE"] && fields["blood_type"])
				if(!M.dna.previous["name"])
					M.dna.previous["name"] = M.real_name
				if(!M.dna.previous["UE"])
					M.dna.previous["UE"] = M.dna.unique_enzymes
				if(!M.dna.previous["blood_type"])
					M.dna.previous["blood_type"] = M.dna.blood_type
				M.real_name = fields["name"]
				M.dna.unique_enzymes = fields["UE"]
				M.name = M.real_name
				M.dna.blood_type = fields["blood_type"]
				M.dna.temporary_mutations[UE_CHANGED] = endtime
			if(fields["UI"])	//UI+UE
				if(!M.dna.previous["UI"])
					M.dna.previous["UI"] = M.dna.uni_identity
				M.dna.uni_identity = merge_text(M.dna.uni_identity, fields["UI"])
				M.updateappearance(mutations_overlay_update=1)
				M.dna.temporary_mutations[UI_CHANGED] = endtime
		log_attack("[log_msg] [loc_name(user)]")
		return TRUE
	else
		return FALSE

/obj/item/dnainjector/timed/hulk
	name = "\improper iniektor DNA (Hulk)"
	desc = "Zrobi z ciebie wielkiego siłacza, ale zepsuje ci cerę."
	add_mutations = list(HULK)

/obj/item/dnainjector/timed/h2m
	name = "\improper iniektor DNA (Człowiek > Małpa)"
	desc = "Zrobi z ciebie pchlarza."
	add_mutations = list(RACEMUT)

/obj/item/dnainjector/activator
	name = "\improper aktywator DNA"
	desc = "Po wstrzyknięciu aktywuje bieżącą mutację, jeśli badany ją ma."
	var/doitanyway = FALSE
	var/research = FALSE //Set to true to get expended and filled injectors for chromosomes
	var/filled = FALSE

/obj/item/dnainjector/activator/inject(mob/living/carbon/M, mob/user)
	if(M.has_dna() && !HAS_TRAIT(M, TRAIT_RADIMMUNE) && !HAS_TRAIT(M, TRAIT_BADDNA))
		M.radiation += rand(20/(damage_coeff  ** 2),50/(damage_coeff  ** 2))
		var/log_msg = "[key_name(user)] injected [key_name(M)] with the [name]"
		for(var/mutation in add_mutations)
			var/datum/mutation/HM = mutation
			if(istype(HM, /datum/mutation))
				mutation = HM.type
			if(!M.dna.activate_mutation(HM))
				if(!doitanyway)
					log_msg += "(FAILED)"
				else
					M.dna.add_mutation(HM, MUT_EXTRA)
			else if(research && M.client)
				filled = TRUE
			log_msg += "([mutation])"
		if(filled)
			name = "[name] (napełniony)"
		else
			name = "[name] (zużyty)"
		log_attack("[log_msg] [loc_name(user)]")
		return TRUE
	return FALSE
