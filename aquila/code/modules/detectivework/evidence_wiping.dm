// AQUILA - zacieranie śladów (Space Station 14: CleansForensics i Residue). Mydłem albo szmatą, prawym przyciskiem
// (w starym trybie intencja rozbrajania) na przedmiocie albo strukturze: 12 s pracy usuwa odciski, włókna i krew.
// Krew i tak zostaje dla luminolu, a na przedmiocie zostaje ślad czyszczenia, który skaner detektywa widzi
// i który słabnie jak ślady prochu (10 min wyraźny, po 20 min znika). Szmata zostawia też swoje włókna.
// Mop, prysznic, środek czyszczący i cleanbot dalej odcisków nie ścierają.

#define EVIDENCE_WIPE_TIME (12 SECONDS)

/datum/component/forensics
	/// Ślady czyszczenia: opis => world.time
	var/list/cleaning_residue

/datum/component/forensics/InheritComponent(datum/component/forensics/F, original)
	if(length(F.cleaning_residue))
		LAZYINITLIST(cleaning_residue)
		for(var/residue in F.cleaning_residue)
			cleaning_residue[residue] = max(cleaning_residue[residue], F.cleaning_residue[residue])
	return ..()

/// Ślady czyszczenia, które jeszcze nie zniknęły: opis => wiek
/datum/component/forensics/proc/get_cleaning_residue()
	if(!length(cleaning_residue))
		return null
	var/list/result = list()
	for(var/residue in cleaning_residue)
		var/age = world.time - cleaning_residue[residue]
		if(age >= GSR_FADE_TIME)
			cleaning_residue -= residue
			continue
		result[residue] = age
	if(!length(cleaning_residue))
		cleaning_residue = null
	return length(result) ? result : null

/// Zaciera ślady: odciski, włókna, krew (zostaje utajona dla luminolu), dopisuje ślad czyszczenia
/atom/proc/aq_wipe_evidence(residue, fiber)
	var/datum/component/forensics/D = AddComponent(/datum/component/forensics)
	if(!D)
		return FALSE
	// krew zwykłą ścieżką czyszczenia: zdejmuje nakładkę „zakrwawiony”, a DNA zostaje utajone dla luminolu.
	// Ta ścieżka zmywa też ślady prochu, a zacieranie ich nie rusza (znikają według własnych zasad): zachowujemy je
	var/list/residue_backup = D.gunshot_residue?.Copy()
	SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
	D = GetComponent(/datum/component/forensics) || AddComponent(/datum/component/forensics)
	if(length(residue_backup))
		D.gunshot_residue = residue_backup
	D.wipe_fingerprints()
	D.wipe_fibers()
	LAZYSET(D.cleaning_residue, residue, world.time)
	if(fiber)
		D.add_fiber_list(list(fiber))
		LAZYSET(D.fiber_times, fiber, world.time)
	return TRUE

/atom/proc/return_cleaning_residue()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		. = D.get_cleaning_residue()

/// Wspólne dla mydła i szmaty: prawy przycisk na przedmiocie albo strukturze w zasięgu ręki
/proc/aq_try_wipe_evidence(obj/item/tool, atom/target, mob/living/user, residue, fiber)
	if(!isobj(target) || ismob(target) || !user.Adjacent(target))
		return FALSE
	user.visible_message("<span class='notice'>[user] starannie wyciera [target] [tool].</span>", "<span class='notice'>Zaczynasz starannie wycierać [target] [tool], żeby zatrzeć ślady...</span>")
	if(!do_after(user, EVIDENCE_WIPE_TIME, target = target))
		return TRUE
	target.aq_wipe_evidence(residue, fiber)
	to_chat(user, "<span class='notice'>Ścierasz ślady z [target].</span>")
	return TRUE

/obj/item/soap/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag || !isliving(user) || !aq_try_wipe_evidence(src, target, user, "ślady mydła"))
		return ..()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/reagent_containers/glass/rag/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag || !isliving(user) || !aq_try_wipe_evidence(src, target, user, "ślady wycierania szmatą", "Włókna ze szmaty."))
		return ..()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/soap/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[capitalize(user.secondary_click_text())] na przedmiocie albo meblu: starannie zetrzyj ślady (12 s).</span>"

/obj/item/reagent_containers/glass/rag/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[capitalize(user.secondary_click_text())] na przedmiocie albo meblu: starannie zetrzyj ślady (12 s).</span>"

#undef EVIDENCE_WIPE_TIME
