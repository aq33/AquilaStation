// AQUILA - BloodTrak (Goonstation code/obj/item/pinpointer.dm, bloodtracker). Przyłożony do świeżej plamy krwi
// pokazuje kierunek do jej właściciela. Zaschnięta krew (u nas schnie po minucie i więcej) nic nie daje,
// tak samo krew na przedmiotach. Mokra kałuża daje 8 minut śledzenia, zwykła plama 4.

#define BLOODTRAK_TIME (4 MINUTES)
#define BLOODTRAK_TIME_WET (8 MINUTES)

/obj/item/pinpointer/aq_bloodtrak
	name = "BloodTrak"
	desc = "Wskaźnik detektywa: przyłóż do świeżej plamy krwi, a pokaże kierunek do jej właściciela, póki krew nie zaschnie."
	color = "#ff8080"
	process_scan = FALSE
	/// Do kiedy śledzi cel
	var/tracking_until = 0

/obj/item/pinpointer/aq_bloodtrak/attack_self(mob/living/user)
	if(!active)
		to_chat(user, "<span class='notice'>Przyłóż [src] do świeżej plamy krwi.</span>")
		return
	toggle_on()
	to_chat(user, "<span class='notice'>Wyłączasz [src].</span>")

/obj/item/pinpointer/aq_bloodtrak/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	var/obj/effect/decal/cleanable/blood/blood = istype(target, /obj/effect/decal/cleanable/blood) ? target : locate(/obj/effect/decal/cleanable/blood) in get_turf(target)
	var/result = track_blood(blood)
	if(istext(result))
		to_chat(user, "<span class='warning'>[result]</span>")
	else
		to_chat(user, "<span class='notice'>[src] łapie trop. Śledzenie przez [DisplayTimeText(tracking_until - world.time)].</span>")

/// Ustawia cel z plamy krwi. Zwraca TRUE albo tekst błędu
/obj/item/pinpointer/aq_bloodtrak/proc/track_blood(obj/effect/decal/cleanable/blood/blood)
	if(!istype(blood))
		return "Tu nie ma plamy krwi."
	if(blood.is_old)
		return "Krew już zaschła."
	var/list/dna = blood.return_blood_DNA()
	if(!length(dna))
		return "W tej krwi nie ma DNA."
	var/mob/living/carbon/human/owner
	for(var/mob/living/carbon/human/H in GLOB.carbon_list)
		if(H.dna && (H.dna.unique_enzymes in dna))
			owner = H
			break
	if(!owner)
		return "Nie ma śladu właściciela tej krwi."
	target = owner
	tracking_until = world.time + (blood.bloodiness >= BLOOD_SLIPPERY_TRESHOLD ? BLOODTRAK_TIME_WET : BLOODTRAK_TIME)
	if(!active)
		toggle_on()
	update_icon()
	return TRUE

/obj/item/pinpointer/aq_bloodtrak/process()
	if(active && (world.time > tracking_until || QDELETED(target)))
		visible_message("<span class='notice'>[src] piszczy: krew zaschła, trop urwany.</span>")
		toggle_on()
		return PROCESS_KILL
	return ..()

#undef BLOODTRAK_TIME
#undef BLOODTRAK_TIME_WET
