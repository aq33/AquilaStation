// AQUILA - cechy (quirki) z innych kodów, grupa „zmysły”
// Łysina, Rozbiegane Oczy, Niezdara, Analfabeta, Światłowstręt, Cichy Głos, Mocny Rzut, Anosmia,
// Okaleczone Oko, Dotykalski, Bez Powiek, Czuły Nos, Chrapanie, Oszczędności Życia, Brudas,
// Właściciel Zwierzaka, Kolorysta.
// Źródła: tgstation (code/datums/quirks/), Skyrat/Bubber (life_savings, dirty, pet_owner), Monkestation (colorist),
// Space Station 14 (Snoring).

#define TRAIT_SHIFTY_EYES "shifty_eyes"
#define TRAIT_THROWINGARM "throwing_arm"
#define TRAIT_ANOSMIA "anosmia"
#define TRAIT_KEEN_NOSE "keen_nose"
#define TRAIT_NO_EYELIDS "no_eyelids"
#define TRAIT_TOUCHY "touchy"
#define TRAIT_AQ_DIRTY "aq_dirty"

/// Źródło krótkowzroczności od okaleczonego oka (inne niż ROUNDSTART_TRAIT cechy Krótkowzroczny)
#define SCARRED_EYE_TRAIT "scarred_eye"

/// Cechy, które się wykluczają (nazwy jak w oknie postaci)
/datum/controller/subsystem/processing/quirks/Initialize(timeofday)
	. = ..()
	quirk_blacklist += list(
		list("Anosmia", "Czuły Nos"),
		list("Brudas", "Czyścioszek"),
		list("Okaleczone Oko", "Ślepota"),
	)

// ---------------------------------------------------------------------------
// Łysina (tg: Smooth-Headed)
// ---------------------------------------------------------------------------

/datum/quirk/bald
	name = "Łysina"
	desc = "Nie masz włosów i bardzo się tego wstydzisz! Noś perukę albo przynajmniej zakrywaj czymś głowę."
	icon = "egg"
	value = 0
	gain_text = "<span class='notice'>Twoja głowa jest gładka jak kolano. To okropne.</span>"
	lose_text = "<span class='notice'>Swędzi cię głowa... czyżby odrastały ci włosy?!</span>"
	medical_record_text = "Pacjent stanowczo odmówił zdjęcia nakrycia głowy podczas badania."
	/// Fryzura sprzed cechy, wraca po jej utracie i trafia na perukę
	var/old_hair

/datum/quirk/bald/add()
	var/mob/living/carbon/human/H = quirk_holder
	old_hair = H.hair_style
	H.hair_style = "Bald"
	H.update_hair()
	RegisterSignal(H, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equip))
	RegisterSignal(H, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_unequip))
	update_hat_mood(H.head)

/datum/quirk/bald/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/head/wig/natural/wig = new(get_turf(H))
	if(old_hair && old_hair != "Bald")
		wig.hair_style = old_hair
		wig.update_icon()
	H.equip_in_one_of_slots(wig, list("head" = ITEM_SLOT_HEAD, "backpack" = ITEM_SLOT_BACKPACK, "hands" = ITEM_SLOT_HANDS), qdel_on_fail = FALSE)

/datum/quirk/bald/remove()
	var/mob/living/carbon/human/H = quirk_holder
	UnregisterSignal(H, list(COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_UNEQUIPPED_ITEM))
	SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "bad_hair_day")
	if(QDELETED(H))
		return
	if(H.hair_style == "Bald" && old_hair && old_hair != "Bald")
		H.hair_style = old_hair
		H.update_hair()

/// Peruka cieszy, inne nakrycie głowy uspokaja, goła głowa martwi
/datum/quirk/bald/proc/update_hat_mood(obj/item/hat)
	if(istype(hat, /obj/item/clothing/head/wig))
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "bad_hair_day", /datum/mood_event/aq_confident_mane)
	else if(hat)
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "bad_hair_day")
	else
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "bad_hair_day", /datum/mood_event/aq_bald)

/datum/quirk/bald/proc/on_equip(mob/living/carbon/human/source, obj/item/item, slot)
	SIGNAL_HANDLER
	if(slot == ITEM_SLOT_HEAD)
		update_hat_mood(item)

/datum/quirk/bald/proc/on_unequip(mob/living/carbon/human/source, obj/item/item)
	SIGNAL_HANDLER
	// Sygnał idzie przed wyzerowaniem slotu, więc tu head to jeszcze zdejmowany przedmiot
	if(item && item == source.head)
		update_hat_mood(null)

/datum/mood_event/aq_bald
	description = "<span class='warning'>Muszę czymś zakryć głowę...</span>\n"
	mood_change = -3

/datum/mood_event/aq_confident_mane
	description = "<span class='nicegreen'>Z pełną czupryną czuję się pewnie.</span>\n"
	mood_change = 2

// ---------------------------------------------------------------------------
// Rozbiegane Oczy (tg: Shifty Eyes)
// U nas nie ma kontaktu wzrokowego z tg, więc oglądający czasem ma wrażenie, że posiadacz patrzy prosto na niego.
// ---------------------------------------------------------------------------

/datum/quirk/shifty_eyes
	name = "Rozbiegane Oczy"
	desc = "Twoje oczy błądzą po całym otoczeniu, czy tego chcesz, czy nie, więc ludzie czasem myślą, że patrzysz prosto na nich, choć wcale tak nie jest."
	icon = "eye"
	value = 0
	mob_trait = TRAIT_SHIFTY_EYES
	medical_record_text = "Ten dziwak gapił się na mnie przez całe badanie. Wpisuję diagnozę, bo to mniej krępujące niż myśl, że robił to celowo."

// ---------------------------------------------------------------------------
// Niezdara (tg: Clumsy)
// ---------------------------------------------------------------------------

/datum/quirk/clumsy
	name = "Niezdara"
	desc = "Jesteś niezdarą, gapą i wesołym głuptasem. Mam nadzieję, że nie planujesz używać rąk do niczego, co wymaga choćby odrobiny zręczności."
	icon = "dizzy"
	value = -3
	mob_trait = TRAIT_CLUMSY
	gain_text = "<span class='danger'>Czujesz, jak twoje IQ spływa w dół jak woda.</span>"
	lose_text = "<span class='notice'>Czujesz, że twoje IQ wróciło przynajmniej do średniej.</span>"
	medical_record_text = "Pacjent wykazuje skrajne trudności z precyzyjną motoryką, połączone z niezdolnością do krytycznego myślenia."

// ---------------------------------------------------------------------------
// Analfabeta (tg: Illiterate). Rdzeń już sprawdza ten trait w is_literate()/can_read():
// papier, książki, foldery, gazety, komputery modułowe, klawiatura obwodów.
// ---------------------------------------------------------------------------

/datum/quirk/illiterate
	name = "Analfabeta"
	desc = "Rzuciłeś szkołę i nie umiesz czytać ani pisać. Dotyczy to papierów, książek i komputerów."
	icon = "graduation-cap"
	value = -3
	mob_trait = TRAIT_ILLITERATE
	gain_text = "<span class='danger'>Litery nagle przestają cokolwiek dla ciebie znaczyć.</span>"
	lose_text = "<span class='notice'>Litery znowu układają się w słowa.</span>"
	medical_record_text = "Pacjent nie umie czytać ani pisać."

// ---------------------------------------------------------------------------
// Światłowstręt (tg: Photophobia)
// ---------------------------------------------------------------------------

/datum/quirk/photophobia
	name = "Światłowstręt"
	desc = "Jasne światło przeszkadza ci bardziej niż innym. Może to jakaś choroba."
	icon = "sun"
	value = -1
	gain_text = "<span class='danger'>Światło przestaje dawać ci poczucie bezpieczeństwa...</span>"
	lose_text = "<span class='notice'>Światło znowu przestało ci przeszkadzać.</span>"
	medical_record_text = "Pacjent ma ostry lęk przed światłem i upiera się, że światło mu szkodzi."

/datum/quirk/photophobia/add()
	RegisterSignal(quirk_holder, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(check_eyes))
	RegisterSignal(quirk_holder, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(restore_eyes))
	RegisterSignal(quirk_holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_holder_moved))
	var/mob/living/carbon/C = quirk_holder
	update_eyes(C.getorganslot(ORGAN_SLOT_EYES))

/datum/quirk/photophobia/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN, COMSIG_MOVABLE_MOVED))
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "photophobia")
	var/mob/living/carbon/C = quirk_holder
	var/obj/item/organ/eyes/E = C.getorganslot(ORGAN_SLOT_EYES)
	if(istype(E))
		E.flash_protect = initial(E.flash_protect)

/datum/quirk/photophobia/proc/check_eyes(datum/source, obj/item/organ/eyes/sensitive_eyes)
	SIGNAL_HANDLER
	update_eyes(sensitive_eyes)

/// Oczy dostają o jeden poziom gorszą ochronę przed błyskiem (najwyżej do nadwrażliwości)
/datum/quirk/photophobia/proc/update_eyes(obj/item/organ/eyes/target_eyes)
	if(!istype(target_eyes))
		return
	target_eyes.flash_protect = max(initial(target_eyes.flash_protect) - 1, -1)

/datum/quirk/photophobia/proc/restore_eyes(datum/source, obj/item/organ/eyes/normal_eyes)
	SIGNAL_HANDLER
	if(!istype(normal_eyes))
		return
	normal_eyes.flash_protect = initial(normal_eyes.flash_protect)

/datum/quirk/photophobia/proc/on_holder_moved(mob/living/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	check_light()

/// Jasno i bez ochrony oczu (np. okularów przeciwsłonecznych) = zły humor
/datum/quirk/photophobia/proc/check_light()
	if(quirk_holder.stat != CONSCIOUS || HAS_TRAIT(quirk_holder, TRAIT_FEARLESS))
		return
	if(quirk_holder.sight & SEE_TURFS)
		return
	var/turf/holder_turf = get_turf(quirk_holder)
	if(!holder_turf)
		return
	if(holder_turf.get_lumcount() <= 0.2 || quirk_holder.get_eye_protection() >= 0)
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "photophobia")
		return
	SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "photophobia", /datum/mood_event/aq_photophobia)

/datum/mood_event/aq_photophobia
	description = "<span class='warning'>To światło jest za jasne...</span>\n"
	mood_change = -3

// ---------------------------------------------------------------------------
// Cichy Głos (tg: Soft-Spoken). Używa traitu szeptu wampira, który mowa już sprawdza.
// ---------------------------------------------------------------------------

/datum/quirk/softspoken
	name = "Cichy Głos"
	desc = "Mówisz bardzo cicho i trudno cię usłyszeć: zawsze szepczesz."
	icon = "comment"
	value = -1
	mob_trait = TRAIT_WHISPER_ONLY
	gain_text = "<span class='danger'>Czujesz, że mówisz ciszej.</span>"
	lose_text = "<span class='notice'>Czujesz, że mówisz głośniej.</span>"
	medical_record_text = "Pacjent mówi bardzo cicho i trudno go usłyszeć."

// ---------------------------------------------------------------------------
// Mocny Rzut (tg: Throwing Arm): +2 do zasięgu rzutu i rzut do kosza zawsze trafia
// ---------------------------------------------------------------------------

/datum/quirk/throwingarm
	name = "Mocny Rzut"
	desc = "Masz krzepę w ramionach! Rzucone przez ciebie przedmioty lecą dalej niż u innych, a do kosza trafiasz zawsze."
	icon = "baseball-ball"
	value = 2
	mob_trait = TRAIT_THROWINGARM
	gain_text = "<span class='notice'>Twoje ramiona aż rwą się do rzucania!</span>"
	lose_text = "<span class='danger'>Ramiona trochę cię bolą.</span>"
	medical_record_text = "Pacjent po mistrzowsku rzuca piłką."

/datum/quirk/throwingarm/add()
	RegisterSignal(quirk_holder, COMSIG_MOB_THROW, PROC_REF(on_throw))

/datum/quirk/throwingarm/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOB_THROW)

/// Rzut z ręki albo z chwytu: zasięg dopisujemy, zanim rzucana rzecz poleci
/datum/quirk/throwingarm/proc/on_throw(mob/living/carbon/source, atom/target)
	SIGNAL_HANDLER
	var/atom/movable/thrown = source.get_active_held_item()
	if(!thrown && isliving(source.pulling) && source.grab_state >= GRAB_AGGRESSIVE)
		thrown = source.pulling
	if(thrown)
		RegisterSignal(thrown, COMSIG_MOVABLE_PRE_THROW, PROC_REF(on_pre_throw), override = TRUE)

/datum/quirk/throwingarm/proc/on_pre_throw(atom/movable/source, list/throw_args)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_PRE_THROW)
	if(throw_args[4] == quirk_holder)
		throw_args[2] += 2

/obj/machinery/disposal/bin/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isitem(AM) && AM.CanEnterDisposals() && throwingdatum?.thrower && HAS_TRAIT(throwingdatum.thrower, TRAIT_THROWINGARM))
		AM.forceMove(src)
		visible_message("<span class='notice'>[AM] ląduje w [src].</span>")
		update_icon()
		return
	return ..()

// ---------------------------------------------------------------------------
// Anosmia (tg). Blokuje zapachy z modułu pollution i miazmę (choroba z miazmy zostaje).
// ---------------------------------------------------------------------------

/datum/quirk/anosmia
	name = "Anosmia"
	desc = "Z jakiegoś powodu nie czujesz żadnych zapachów."
	icon = "head-side-cough-slash"
	value = -1
	mob_trait = TRAIT_ANOSMIA
	gain_text = "<span class='notice'>Nie czujesz żadnych zapachów!</span>"
	lose_text = "<span class='danger'>Nagle znowu czujesz zapachy!</span>"
	medical_record_text = "Pacjent utracił węch."

/datum/pollution/smell_act(mob/living/sniffer)
	if(HAS_TRAIT(sniffer, TRAIT_ANOSMIA))
		return
	return ..()

/obj/item/organ/lungs/handle_miasma_breath(mob/living/carbon/human/H, miasma_pp)
	if(miasma_pp >= 1 && H && HAS_TRAIT(H, TRAIT_ANOSMIA))
		clear_miasma_smell(H)
		// Nosa nie ma, ale zarazki z miazmy nadal wchodzą (jak w tg)
		if(prob(0.05 * miasma_pp))
			var/datum/disease/advance/miasma_disease = new /datum/disease/advance/random(2, 3)
			miasma_disease.name = "Unknown"
			H.ForceContractDisease(miasma_disease, FALSE, TRUE)
		return
	return ..()

// ---------------------------------------------------------------------------
// Okaleczone Oko (tg: Scarred Eye). U nas nie ma blizn na oczach: zostaje krótkowzroczność z tg i opaska na oko.
// ---------------------------------------------------------------------------

/datum/quirk/scarred_eye
	name = "Okaleczone Oko"
	desc = "Dawny wypadek kosztował cię jedno oko, ale za to masz świetną opaskę. Arrr!"
	icon = "eye-slash"
	value = -1
	gain_text = "<span class='danger'>Po tylu latach oko wciąż trochę cię piecze...</span>"
	lose_text = "<span class='notice'>Twoje pole widzenia rośnie o jakieś trzydzieści procent.</span>"
	medical_record_text = "Pacjent ma rozległe blizny na jednym oku, przez co częściowo stracił wzrok."

/datum/quirk/scarred_eye/add()
	quirk_holder.become_nearsighted(SCARRED_EYE_TRAIT)

/datum/quirk/scarred_eye/remove()
	if(!QDELETED(quirk_holder))
		quirk_holder.cure_nearsighted(SCARRED_EYE_TRAIT)

/datum/quirk/scarred_eye/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/glasses/eyepatch/eyepatch = new(get_turf(H))
	H.equip_in_one_of_slots(eyepatch, list("eyes" = ITEM_SLOT_EYES, "backpack" = ITEM_SLOT_BACKPACK, "hands" = ITEM_SLOT_HANDS), qdel_on_fail = FALSE)

// ---------------------------------------------------------------------------
// Dotykalski (tg: Touchy): przyjrzeć się (Shift+klik) można tylko temu, czego dosięgasz
// ---------------------------------------------------------------------------

/datum/quirk/touchy
	name = "Dotykalski"
	desc = "Musisz czegoś dotknąć, żeby się temu przyjrzeć: z daleka niczego nie rozpoznasz."
	icon = "hand-paper"
	value = -1
	mob_trait = TRAIT_TOUCHY
	gain_text = "<span class='danger'>Czujesz, że z daleka niczego się nie przyjrzysz.</span>"
	lose_text = "<span class='notice'>Czujesz, że znowu możesz przyglądać się rzeczom z daleka.</span>"
	medical_record_text = "Pacjent nie rozróżnia przedmiotów z odległości."

/datum/quirk/touchy/add()
	RegisterSignal(quirk_holder, COMSIG_MOB_CLICKON, PROC_REF(examinate_check))

/datum/quirk/touchy/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOB_CLICKON)

/datum/quirk/touchy/proc/examinate_check(mob/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(!LAZYACCESS(modifiers, SHIFT_CLICK) || LAZYACCESS(modifiers, CTRL_CLICK) || LAZYACCESS(modifiers, MIDDLE_CLICK))
		return
	if(istype(target, /atom/movable/screen) || target == source || get(target.loc, /mob) == source)
		return
	if(target.Adjacent(source))
		return
	to_chat(source, "<span class='warning'>Musisz podejść i tego dotknąć, żeby się przyjrzeć.</span>")
	return COMSIG_MOB_CANCEL_CLICKON

// ---------------------------------------------------------------------------
// Bez Powiek (tg: Fluoride Stare). Co 3 minuty trzeba nawilżyć oczy solą fizjologiczną (zakraplacz),
// potem 30 s zapasu i oczy zaczynają się niszczyć. Mruganie (eyelids.dm) znika.
// ---------------------------------------------------------------------------

#define FLUORIDE_STARE_INTERVAL (3 MINUTES)
#define FLUORIDE_STARE_GRACE (30 SECONDS)

/datum/quirk/fluoride_stare
	name = "Bez Powiek"
	desc = "Straciłeś powieki w strasznym wypadku, a przynajmniej tak mówisz innym. Co jakiś czas musisz ręcznie nawilżać oczy solą fizjologiczną!"
	icon = "eye-dropper"
	value = -2
	process = TRUE
	gain_text = "<span class='danger'>Oczy swędzą cię i są suche...</span>"
	lose_text = "<span class='notice'>Nagła ciemność okazuje się po prostu twoimi odrośniętymi powiekami.</span>"
	medical_record_text = "Pacjent stracił powieki w makabrycznym wypadku."
	/// Kiedy ostatnio nawilżono oczy
	var/last_wet = 0
	var/warned_grace = FALSE
	var/warned_dying = FALSE

/datum/quirk/fluoride_stare/add()
	ADD_TRAIT(quirk_holder, TRAIT_NO_EYELIDS, ROUNDSTART_TRAIT)
	last_wet = world.time
	RegisterSignal(quirk_holder, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))
	quirk_holder.update_body()

/datum/quirk/fluoride_stare/remove()
	UnregisterSignal(quirk_holder, COMSIG_LIVING_REVIVE)
	REMOVE_TRAIT(quirk_holder, TRAIT_NO_EYELIDS, ROUNDSTART_TRAIT)
	if(!QDELETED(quirk_holder))
		quirk_holder.update_body()

/datum/quirk/fluoride_stare/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/list/slots = list("left pocket" = ITEM_SLOT_LPOCKET, "right pocket" = ITEM_SLOT_RPOCKET, "backpack" = ITEM_SLOT_BACKPACK, "hands" = ITEM_SLOT_HANDS)
	H.equip_in_one_of_slots(new /obj/item/reagent_containers/glass/bottle/salglu_solution(get_turf(H)), slots, qdel_on_fail = FALSE)
	H.equip_in_one_of_slots(new /obj/item/reagent_containers/dropper(get_turf(H)), slots, qdel_on_fail = FALSE)

/datum/quirk/fluoride_stare/on_process(delta_time)
	var/mob/living/carbon/C = quirk_holder
	var/obj/item/organ/eyes/E = C.getorganslot(ORGAN_SLOT_EYES)
	if(!E || E.status == ORGAN_ROBOTIC)
		last_wet = world.time
		return
	if(world.time > last_wet + FLUORIDE_STARE_INTERVAL + FLUORIDE_STARE_GRACE)
		if(!warned_dying)
			to_chat(C, "<span class='userdanger'>Twoje oczy wysychają! Nawilż je solą fizjologiczną!</span>")
			warned_dying = TRUE
		E.applyOrganDamage(0.5 * delta_time)
	else if(world.time > last_wet + FLUORIDE_STARE_INTERVAL)
		if(!warned_grace)
			to_chat(C, "<span class='danger'>Oczy zaczynają cię piec, musisz je nawilżyć!</span>")
			warned_grace = TRUE

/datum/quirk/fluoride_stare/proc/on_revive()
	SIGNAL_HANDLER
	wet_eyes(FALSE)

/// Sól fizjologiczna w oczach (zakraplacz) albo wskrzeszenie
/datum/quirk/fluoride_stare/proc/wet_eyes(notify = TRUE)
	last_wet = world.time
	warned_grace = FALSE
	warned_dying = FALSE
	if(notify)
		to_chat(quirk_holder, "<span class='notice'>Twoje oczy są znowu nawilżone.</span>")

/datum/reagent/medicine/salglu_solution/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	. = ..()
	if(method != TOUCH || reac_volume < 1 || !HAS_TRAIT(M, TRAIT_NO_EYELIDS))
		return
	for(var/datum/quirk/fluoride_stare/quirk in M.roundstart_quirks)
		quirk.wet_eyes()

/// Bez powiek nie ma mrugania (eyelids.dm)
/mob/living/carbon/human/get_eyelid_overlays(mutable_appearance/eye_overlay, obj/item/organ/eyes/eyes, obj/item/bodypart/head/head)
	if(HAS_TRAIT(src, TRAIT_NO_EYELIDS))
		return list()
	return ..()

#undef FLUORIDE_STARE_INTERVAL
#undef FLUORIDE_STARE_GRACE

// ---------------------------------------------------------------------------
// Czuły Nos (tg: Keen Nose): oglądając trzymany otwarty pojemnik, czujesz zapach jego zawartości
// ---------------------------------------------------------------------------

/datum/quirk/keen_nose
	name = "Czuły Nos"
	desc = "Masz bardzo wrażliwy nos. Oglądając otwarty pojemnik, który trzymasz, czujesz zapach jego zawartości."
	icon = "flask"
	value = 1
	mob_trait = TRAIT_KEEN_NOSE
	gain_text = "<span class='notice'>Czujesz wszystkie zapachy wokół o wiele wyraźniej.</span>"
	lose_text = "<span class='danger'>Twój węch wraca do normy.</span>"
	medical_record_text = "Pacjent ma niezwykle czuły zmysł węchu."

/obj/item/reagent_containers/examine(mob/user)
	. = ..()
	if(isliving(user) && HAS_TRAIT(user, TRAIT_KEEN_NOSE))
		var/sniff_text = get_sniff_examine(user)
		if(sniff_text)
			. += sniff_text

/// Opis zapachu zawartości dla Czułego Nosa
/obj/item/reagent_containers/proc/get_sniff_examine(mob/living/carbon/sniffer)
	if(!istype(sniffer) || HAS_TRAIT(sniffer, TRAIT_ANOSMIA))
		return
	if(!is_open_container() || !reagents?.total_volume)
		return
	if(!sniffer.is_holding(src))
		return
	if(!sniffer.get_bodypart(BODY_ZONE_HEAD))
		return
	if(sniffer.is_mouth_covered())
		return "<span class='warning'>Z zakrytą twarzą nie poczujesz zapachu zawartości.</span>"
	return "<span class='notice'>Wąchasz zawartość. Czujesz zapach: [reagents.generate_taste_message(10)].</span>"

// ---------------------------------------------------------------------------
// Chrapanie (SS14/Einstein Engines: Snoring): emotka chrapania we śnie
// ---------------------------------------------------------------------------

/datum/quirk/snoring
	name = "Chrapanie"
	desc = "Głośno chrapiesz, kiedy śpisz."
	icon = "moon"
	value = 0
	process = TRUE
	medical_record_text = "Pacjent zgłasza, że współlokatorzy skarżą się na jego chrapanie."

/datum/quirk/snoring/on_process(delta_time)
	if(quirk_holder.IsSleeping() && DT_PROB(8, delta_time))
		quirk_holder.emote("snore")

// ---------------------------------------------------------------------------
// Oszczędności Życia (Skyrat/Bubber: Life Savings): +25% każdej wypłaty z prywatnego funduszu
// ---------------------------------------------------------------------------

#define LIFE_SAVINGS_BONUS 0.25

/datum/bank_account
	/// Cecha Oszczędności Życia: dopłata do każdej wypłaty
	var/aq_life_savings = FALSE

/datum/bank_account/payday(amt_of_paychecks, free = FALSE)
	. = ..()
	if(!aq_life_savings || (!. && !free))
		return
	var/funds = round(paycheck_amount * amt_of_paychecks * LIFE_SAVINGS_BONUS)
	if(funds <= 0)
		return
	adjust_money(funds)
	bank_card_talk("Dopłata z prywatnego funduszu: $[funds].")

/datum/quirk/life_savings
	name = "Oszczędności Życia"
	desc = "Bogaci się bogacą. Dzięki sprytnym inwestycjom albo znajomościom z każdą wypłatą dostajesz dodatkowe kredyty. Wydaj je mądrze albo przepuść na używki, w końcu są twoje."
	icon = "piggy-bank"
	value = 2
	medical_record_text = "Pacjent może mieć przy sobie sporą sumę. Warto poprosić o drobną pożyczkę, tak byłoby sprawiedliwie."
	/// Konto, któremu włączyliśmy dopłatę
	var/datum/bank_account/owner_account

/datum/quirk/life_savings/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	owner_account = H.get_bank_account()
	if(owner_account)
		owner_account.aq_life_savings = TRUE

/datum/quirk/life_savings/remove()
	if(owner_account)
		owner_account.aq_life_savings = FALSE
		owner_account = null

#undef LIFE_SAVINGS_BONUS

// ---------------------------------------------------------------------------
// Brudas (Bubber: Dirty). Roznosi brud, a mycie (prysznic, mydło) go zasmuca. Bez kupek śmieci z Bubbera
// brud wraca sam po 10 minutach.
// ---------------------------------------------------------------------------

#define DIRTY_TILE_CHANCE 1
#define DIRTY_WASH_THRESHOLD 20
#define DIRTY_REDIRTY_TIME (10 MINUTES)

/datum/quirk/dirty
	name = "Brudas"
	desc = "Od baaardzo dawna nie brałeś prysznica, więc pokrywa cię gruba warstwa brudu, którą roznosisz wszędzie."
	icon = "trash-alt"
	value = -1
	mob_trait = TRAIT_AQ_DIRTY
	gain_text = "<span class='danger'>Czujesz się brudny!</span>"
	lose_text = "<span class='notice'>W końcu jesteś czysty...</span>"
	medical_record_text = "Pacjent ma koszmarne nawyki higieniczne."
	/// Umyty: nie roznosi brudu, dopóki brud nie wróci
	var/cleaned = FALSE
	var/redirty_timer

/datum/quirk/dirty/add()
	RegisterSignal(quirk_holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/datum/quirk/dirty/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOVABLE_MOVED)
	deltimer(redirty_timer)
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "dirty_quirk_washed")

/datum/quirk/dirty/post_add()
	to_chat(quirk_holder, "<span class='notice'>Jesteś brudny! Chodząc, roznosisz brud. Mycie zmyje go z ciebie, ale po jakimś czasie wróci.</span>")

/datum/quirk/dirty/proc/on_moved(atom/movable/mover, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	if(cleaned || !prob(DIRTY_TILE_CHANCE))
		return
	if(!(quirk_holder.mobility_flags & MOBILITY_STAND) || (quirk_holder.movement_type & (FLYING | FLOATING)))
		return
	var/turf/open/floor/new_turf = get_turf(quirk_holder)
	if(!istype(new_turf) || (locate(/obj/effect/decal/cleanable/dirt) in new_turf))
		return
	new /obj/effect/decal/cleanable/dirt(new_turf)

/// Wołane z on_hygiene_changed() przy dużym skoku higieny (prysznic, mydło)
/datum/quirk/dirty/proc/on_washed()
	if(cleaned)
		return
	cleaned = TRUE
	INVOKE_ASYNC(quirk_holder, TYPE_PROC_REF(/mob, emote), "scream")
	quirk_holder.visible_message("<span class='warning'>[quirk_holder] wije się i miota, walcząc z myciem!</span>", \
		"<span class='userdanger'>Nie! NIE! Twój brud! Zniknął!</span>")
	SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "dirty_quirk_washed", /datum/mood_event/aq_dirty_washed)
	deltimer(redirty_timer)
	redirty_timer = addtimer(CALLBACK(src, PROC_REF(redirty)), DIRTY_REDIRTY_TIME, TIMER_STOPPABLE)

/datum/quirk/dirty/proc/redirty()
	redirty_timer = null
	if(!cleaned || QDELETED(quirk_holder))
		return
	cleaned = FALSE
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "dirty_quirk_washed")
	quirk_holder.visible_message("<span class='warning'>[quirk_holder] znowu jest cały w brudzie. Z jego higieną nic się nie da zrobić.</span>", \
		"<span class='notice'>Znowu pokrywa cię warstwa brudu. Czujesz ulgę.</span>")

/datum/mood_event/aq_dirty_washed
	description = "<span class='warning'>Co to za zapach...? Lawendowe mydło? Nuta cytrusów?! OHYDA! Muszę się wytarzać w brudzie!</span>\n"
	mood_change = -6

/mob/living/carbon/human/on_hygiene_changed(old_hygiene)
	. = ..()
	if(hygiene - old_hygiene >= DIRTY_WASH_THRESHOLD && HAS_TRAIT(src, TRAIT_AQ_DIRTY))
		for(var/datum/quirk/dirty/quirk in roundstart_quirks)
			quirk.on_washed()

#undef DIRTY_TILE_CHANCE
#undef DIRTY_WASH_THRESHOLD
#undef DIRTY_REDIRTY_TIME

/// Opisy przy oglądaniu: Brudas i Rozbiegane Oczy (examine człowieka nie wysyła COMSIG_PARENT_EXAMINE)
/mob/living/carbon/human/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_AQ_DIRTY))
		var/dirty = FALSE
		for(var/datum/quirk/dirty/quirk in roundstart_quirks)
			if(!quirk.cleaned)
				dirty = TRUE
		if(dirty)
			. += "<span class='warning'>Ta osoba jest cała w brudzie i roznosi go wszędzie!</span>"
	if(HAS_TRAIT(src, TRAIT_SHIFTY_EYES) && user != src && isliving(user) && stat == CONSCIOUS)
		var/dist = get_dist(user, src)
		if(dist <= 5 && !is_eyes_covered() && prob(10 - dist))
			. += "<span class='notice'>Nawiązujesz kontakt wzrokowy z [src].</span>"

// ---------------------------------------------------------------------------
// Właściciel Zwierzaka (Bubber/Paradise: Pet Owner): losowy zwierzak w zamkniętym transporterze i obroża do nadania imienia
// ---------------------------------------------------------------------------

GLOBAL_LIST_INIT(aq_quirk_pet_types, list(
	/mob/living/basic/pet/dog/corgi,
	/mob/living/basic/pet/dog/corgi/puppy,
	/mob/living/basic/pet/dog/pug,
	/mob/living/basic/pet/dog/bullterrier,
	/mob/living/basic/pet/cat,
	/mob/living/basic/pet/cat/kitten,
	/mob/living/basic/pet/fox/docile,
	/mob/living/basic/pet/penguin/baby/permanent,
	/mob/living/basic/pet/hamster,
	/mob/living/basic/chick/permanent,
	/mob/living/basic/rabbit,
	/mob/living/basic/lizard,
	/mob/living/basic/frog,
	/mob/living/basic/crab,
	/mob/living/basic/butterfly,
	/mob/living/basic/mothroach,
	/mob/living/basic/sloth,
	/mob/living/basic/snake,
))

/datum/quirk/pet_owner
	name = "Właściciel Zwierzaka"
	desc = "Zabierasz zwierzaka ze sobą do pracy, żeby on też mógł zaznać niebezpieczeństw życia na pokładzie."
	icon = "paw"
	value = 0
	gain_text = "<span class='notice'>Zabrałeś do pracy swojego zwierzaka.</span>"
	lose_text = "<span class='danger'>Czujesz się samotny, jakbyś kogoś zostawił...</span>"
	medical_record_text = "Pacjent z czułością opowiada o swoim zwierzaku."

/datum/quirk/pet_owner/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/pet_type = pick(GLOB.aq_quirk_pet_types)
	var/obj/item/pet_carrier/carrier = new(get_turf(H))
	var/mob/living/pet = new pet_type(carrier)
	pet.befriend(H)
	carrier.add_occupant(pet)
	carrier.open = FALSE
	carrier.update_icon()
	H.equip_in_one_of_slots(carrier, list("hands" = ITEM_SLOT_HANDS, "backpack" = ITEM_SLOT_BACKPACK), qdel_on_fail = FALSE)
	var/obj/item/clothing/neck/petcollar/collar = new(get_turf(H))
	H.equip_in_one_of_slots(collar, list("backpack" = ITEM_SLOT_BACKPACK, "hands" = ITEM_SLOT_HANDS), qdel_on_fail = FALSE)

/datum/quirk/pet_owner/post_add()
	to_chat(quirk_holder, "<span class='boldnotice'>Twój zwierzak czeka w transporterze. Imię nadasz mu obrożą.</span>")

// ---------------------------------------------------------------------------
// Kolorysta (Monkestation/Yogstation: Colorist): farba do włosów w sprayu nakładająca cieniowanie
// ---------------------------------------------------------------------------

/datum/quirk/colorist
	name = "Kolorysta"
	desc = "Lubisz nosić przy sobie farbę do włosów w sprayu, żeby szybko nakładać na włosy kolorowe wzory."
	icon = "fill-drip"
	value = 0
	medical_record_text = "Pacjent lubi farbować włosy na ładne kolory."

/datum/quirk/colorist/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	H.equip_in_one_of_slots(new /obj/item/dyespray(get_turf(H)), list("backpack" = ITEM_SLOT_BACKPACK, "hands" = ITEM_SLOT_HANDS), qdel_on_fail = FALSE)

/obj/item/dyespray
	name = "farba do włosów w sprayu"
	desc = "Spray, którym ufarbujesz włosy w dowolne cieniowanie."
	icon = 'aquila/icons/obj/dyespray.dmi'
	icon_state = "dyespray"
	w_class = WEIGHT_CLASS_TINY

/obj/item/dyespray/attack_self(mob/user)
	dye(user, user)

/obj/item/dyespray/pre_attack(atom/target, mob/living/user, params)
	if(ishuman(target))
		INVOKE_ASYNC(src, PROC_REF(dye), target, user)
		return FALSE
	return ..()

/// Cieniowanie włosów: wzór i drugi kolor. Wzór „None” zmienia zwykły kolor włosów.
/obj/item/dyespray/proc/dye(mob/target, mob/user)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/human_target = target
	var/new_grad_style = tgui_input_list(user, "Wybierz wzór koloru", "Farba do włosów", GLOB.hair_gradients_list)
	if(isnull(new_grad_style) || QDELETED(src) || !user.canUseTopic(src, BE_CLOSE))
		return
	var/new_grad_color = tgui_color_picker(user, "Wybierz drugi kolor włosów:", "Farba do włosów", "#[human_target.gradient_color]")
	if(!new_grad_color || QDELETED(src) || !user.canUseTopic(src, BE_CLOSE) || !user.Adjacent(human_target))
		return
	to_chat(user, "<span class='notice'>Zaczynasz nakładać farbę do włosów...</span>")
	if(!do_after(user, 3 SECONDS, target = human_target))
		return
	if(new_grad_style == "None")
		human_target.hair_color = sanitize_hexcolor(new_grad_color, 6)
	else
		human_target.gradient_style = new_grad_style
		human_target.gradient_color = sanitize_hexcolor(new_grad_color, 6)
	human_target.update_hair()
	playsound(src, 'sound/effects/spray.ogg', 10, TRUE)
