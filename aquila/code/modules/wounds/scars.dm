// AQUILA - scars from tgstation (code/datums/wounds/scars/_scars.dm), in-round only. A serious wound that heals
// (not one replaced by a worse one, not a full heal) leaves a scar on the limb. Scars show on examine when the limb
// isn't covered by clothing, and stay on the limb when it's cut off. Not saved between rounds.

/// Most scars one limb keeps, the oldest fade first
#define MAX_SCARS_PER_LIMB 4

/datum/scar
	/// "długą bliznę po cięciu", read as "Ma [description] ([limb])"
	var/description
	var/severity = WOUND_SEVERITY_SEVERE

/datum/scar/New(description, severity)
	src.description = description
	src.severity = severity

/obj/item/bodypart
	var/list/datum/scar/scars

/obj/item/bodypart/proc/add_scar(description, severity = WOUND_SEVERITY_SEVERE)
	LAZYADD(scars, new /datum/scar(description, severity))
	if(length(scars) > MAX_SCARS_PER_LIMB)
		scars.Cut(1, 2)

/obj/item/bodypart/examine(mob/user)
	. = ..()
	for(var/datum/scar/scar as anything in scars)
		. += "<span class='notice'>Widać na niej [scar.description].</span>"

/datum/wound/Destroy()
	if(!replaced && limb && victim && limb.owner == victim)
		var/scar_text = get_scar_description()
		if(scar_text)
			limb.add_scar(scar_text, severity)
	return ..()

/// Scar left when this wound heals, null for none
/datum/wound/proc/get_scar_description()
	return null

/datum/wound/blunt/fracture/get_scar_description()
	return "lekko skrzywioną kość po dawnym złamaniu"

/datum/wound/blunt/compound/get_scar_description()
	return pick("grubą bliznę i krzywą kość po złamaniu otwartym", "zgrubiałą bliznę w miejscu, gdzie kość przebiła skórę")

/datum/wound/slash/deep/get_scar_description()
	return pick("długą bliznę po cięciu", "jasną, prostą bliznę po głębokim rozcięciu")

/datum/wound/slash/artery/get_scar_description()
	return pick("grubą, poszarpaną bliznę po przeciętej tętnicy", "szeroką bliznę ze śladami szwów")

/datum/wound/pierce/get_scar_description()
	if(wound_source_is_projectile)
		return severity >= WOUND_SEVERITY_SEVERE ? "dwie okrągłe blizny po przestrzale na wylot" : "okrągłą bliznę po postrzale"
	if(severity >= WOUND_SEVERITY_SEVERE)
		return "głęboką, wklęsłą bliznę po ranie kłutej"
	return null

/datum/wound/pierce/eye/get_scar_description()
	return "bliznę przecinającą [side] oko"

/datum/wound/burn/second_degree/get_scar_description()
	return "plamę błyszczącej, zabliźnionej skóry po oparzeniu"

/datum/wound/burn/third_degree/get_scar_description()
	return pick("rozległą, pomarszczoną bliznę po oparzeniu", "twardą, pozbawioną włosów skórę po ciężkim oparzeniu")

/datum/wound/cranial_fissure/get_scar_description()
	return "wgłębienie w czaszce i bliznę po jej pęknięciu"

/// Scars on uncovered limbs on the person's examine
/mob/living/carbon/human/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_HUSK))
		return
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(!LAZYLEN(limb.scars) || is_limb_covered(limb))
			continue
		for(var/datum/scar/scar as anything in limb.scars)
			. += "<span class='notice'>Ma [scar.description] ([limb.name]).</span>"

/mob/living/carbon/fully_heal(admin_revive = FALSE)
	. = ..()
	if(!admin_revive)
		return
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		limb.scars = null

#undef MAX_SCARS_PER_LIMB
