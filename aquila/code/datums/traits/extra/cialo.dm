// AQUILA - cechy postaci z innych kodów, grupa „ciało”.
/// Mob napił się z napoju (food/drinks): (obj/item/drink, foodtype)
#define COMSIG_AQ_LIVING_DRINK "aq_living_drink"
// Źródła: tgstation code/datums/quirks/ (większość), Skyrat modular_skyrat/modules/quirks/ (Fragility, Hardened Soles),
// Monkestation (Hardened Soles), Nova (Hungry), Yogstation code/datums/traits/negative.dm (Hemophiliac).
// Wartości są przeliczone na naszą skalę (tg / 4, zaokrąglone; najsilniejsza zaleta Bee ma 2).
// Uproszczenia względem oryginałów są opisane przy każdej cesze.

#ifndef TRAIT_STRONG_STOMACH
#define TRAIT_STRONG_STOMACH "strong_stomach"
#endif
#ifndef TRAIT_IMMUNODEFICIENCY
#define TRAIT_IMMUNODEFICIENCY "immunodeficiency"
#endif
#ifndef TRAIT_HARD_SOLES
#define TRAIT_HARD_SOLES "hard_soles"
#endif
#define TRAIT_AQ_GLASS_JAW "aq_glass_jaw"
#define TRAIT_AQ_HEMOPHILIA "aq_hemophilia"
/// Trait source of Death Mimicry's fake death
#define AQ_DEATH_MIMICRY_TRAIT "aq_death_mimicry"
/// Hemophilia: natural clotting (bleed_heal_multiplier) is this many times slower
#define AQ_HEMOPHILIA_CLOTTING 0.2
/// Hemophilia: blood lost from bleeding is multiplied by this (physiology.bleed_mod)
#define AQ_HEMOPHILIA_BLEED_MOD 1.5
/// Limper: slowdown without a cane (our critical blunt wound limps with 1.5; tg: "same as compound fracture")
#define AQ_LIMPER_SLOWDOWN 1.5
#define AQ_HUNGRY_MOD 2

/// Puts a starting item from a quirk into the backpack, a pocket or the hands. Returns where it went (Polish text).
/datum/quirk/proc/aq_cialo_give_item(obj/item/item)
	var/mob/living/carbon/human/H = quirk_holder
	if(!istype(H))
		qdel(item)
		return null
	var/list/slots = list(
		"w plecaku" = ITEM_SLOT_BACKPACK,
		"w lewej kieszeni" = ITEM_SLOT_LPOCKET,
		"w prawej kieszeni" = ITEM_SLOT_RPOCKET,
	)
	. = H.equip_in_one_of_slots(item, slots, FALSE)
	if(.)
		return
	if(H.put_in_hands(item))
		return "w rękach"
	return "pod stopami"

/datum/controller/subsystem/processing/quirks/Initialize(timeofday)
	. = ..()
	quirk_blacklist += list(
		list("Poczwórna amputacja", "Proteza"),
		list("Blaszany drwal", "Protetyczny organ"),
	)

// ---------------------------------------------------------------------------
// Alergia na leki (tg: Extreme Medicine Allergy). Alergeny i reakcja jak w mutacji „Alergia na chemikalia”
// (aquila/code/datums/mutations/tg/body.dm), ale cecha uczula tylko na kilka wylosowanych środków. Bez nieśmiertelnika
// z tg: lista alergenów trafia do karty medycznej i na czat.

/datum/quirk/allergic
	name = "Alergia na leki"
	desc = "Od dziecka masz silną alergię na niektóre leki..."
	icon = "allergies"
	value = -2
	gain_text = "<span class='danger'>Czujesz, że twój układ odpornościowy się zmienia.</span>"
	lose_text = "<span class='notice'>Twój układ odpornościowy wraca do pełnej sprawności.</span>"
	medical_record_text = "Układ odpornościowy pacjenta gwałtownie reaguje na niektóre leki."
	process = TRUE
	/// Medicine types we react to
	var/list/allergies = list()
	var/allergy_string

/datum/quirk/allergic/add()
	var/list/chem_list = list()
	for(var/path in aq_chemical_allergy_reagents())
		var/datum/reagent/chem = GLOB.chemical_reagents_list[path]
		if(!chem?.name || (chem.chem_flags & CHEMICAL_NOT_SYNTH))
			continue
		chem_list += path
	var/list/chem_names = list()
	for(var/i in 1 to 6)
		if(!length(chem_list))
			break
		var/path = pick_n_take(chem_list)
		allergies += path
		var/datum/reagent/chem = GLOB.chemical_reagents_list[path]
		chem_names += chem.name
	allergy_string = chem_names.Join(", ")
	medical_record_text = "Układ odpornościowy pacjenta gwałtownie reaguje na: [allergy_string]."

/datum/quirk/allergic/clone_data()
	return allergies.Copy()

/datum/quirk/allergic/on_clone(data)
	if(!length(data))
		return
	allergies = data
	var/list/chem_names = list()
	for(var/path in allergies)
		var/datum/reagent/chem = GLOB.chemical_reagents_list[path]
		if(chem?.name)
			chem_names += chem.name
	allergy_string = chem_names.Join(", ")
	medical_record_text = "Układ odpornościowy pacjenta gwałtownie reaguje na: [allergy_string]."

/datum/quirk/allergic/post_add()
	to_chat(quirk_holder, "<span class='boldnotice'>Masz alergię na: <i>[allergy_string]</i>. Uważaj, żeby ich nie przyjąć!</span>")

/datum/quirk/allergic/on_process(delta_time)
	var/mob/living/carbon/C = quirk_holder
	if(!istype(C) || !C.reagents || C.IsInStasis())
		return
	for(var/datum/reagent/chem as anything in C.reagents.reagent_list)
		if((chem.type in allergies) && chem.volume >= 1)
			aq_chemical_allergy_reaction(C, delta_time)
			return

// ---------------------------------------------------------------------------
// Narkolepsja (tg). Trwały uraz jak tg narcolepsy/permanent: rzadziej zasypiasz, ale śpisz dłużej; przed snem
// przychodzi senność. Modafinil i synaptyzyna chronią, kawa zmniejsza szansę o połowę (tg: TRAIT_STIMULATED).

/datum/brain_trauma/severe/narcolepsy/aq_permanent
	scan_desc = "przewlekła narkolepsja"
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_ABSOLUTE
	/// Percent per second
	var/sleep_chance = 0.333
	var/sleep_chance_running = 0.333
	var/sleep_chance_drowsy = 1

// Pełne zastąpienie snu z rodzica: inne szanse i najpierw senność (tg)
/datum/brain_trauma/severe/narcolepsy/aq_permanent/on_life()
	if(owner.IsSleeping())
		return
	for(var/medicine in list(/datum/reagent/medicine/modafinil, /datum/reagent/medicine/synaptizine))
		if(owner.reagents.has_reagent(medicine))
			return
	var/drowsy = owner.drowsyness > 0
	var/final_chance = sleep_chance
	if(owner.m_intent == MOVE_INTENT_RUN)
		final_chance += sleep_chance_running
	if(drowsy)
		final_chance += sleep_chance_drowsy
	if(owner.reagents.has_reagent(/datum/reagent/consumable/coffee))
		final_chance *= 0.5
	if(!prob(final_chance * 2)) // Life co 2 s
		return
	if(!drowsy)
		to_chat(owner, "<span class='warning'>Czujesz się zmęczony...</span>")
		owner.drowsyness += rand(10, 15)
		if(prob(50))
			owner.emote("yawn")
		return
	to_chat(owner, "<span class='warning'>Zasypiasz.</span>")
	owner.Sleeping(rand(20 SECONDS, 30 SECONDS))
	if(prob(50) && owner.IsSleeping())
		owner.emote("snore")

/datum/quirk/narcolepsy
	name = "Narkolepsja"
	desc = "Często czujesz senność i w każdej chwili możesz zasnąć. Kofeina, chodzenie zamiast biegania albo leki pobudzające pomogą ci przetrwać zmianę..."
	icon = "moon"
	value = -2
	medical_record_text = "Pacjent może mimowolnie zasypiać podczas zwykłych czynności i w każdej chwili odczuwać senność."
	var/where

/datum/quirk/narcolepsy/add()
	var/mob/living/carbon/C = quirk_holder
	C.gain_trauma(/datum/brain_trauma/severe/narcolepsy/aq_permanent, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/narcolepsy/remove()
	var/mob/living/carbon/C = quirk_holder
	if(!QDELETED(C))
		C.cure_trauma_type(/datum/brain_trauma/severe/narcolepsy/aq_permanent, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/narcolepsy/on_spawn()
	where = aq_cialo_give_item(new /obj/item/storage/pill_bottle/stimulant(get_turf(quirk_holder)))

/datum/quirk/narcolepsy/post_add()
	if(where)
		to_chat(quirk_holder, "<span class='boldnotice'>Dostajesz pojemnik z pigułkami pobudzającymi ([where]), żeby nie zasnąć w trakcie zmiany.</span>")

// ---------------------------------------------------------------------------
// Szklana szczęka (tg: Glass Jaw). Liczy obrażenia po pancerzu, bez poprawki tg na ostre przedmioty.

/datum/quirk/glass_jaw
	name = "Szklana szczęka"
	desc = "Masz bardzo delikatną szczękę. Każdy dostatecznie mocny cios w głowę może cię znokautować."
	icon = "fist-raised"
	value = -1
	mob_trait = TRAIT_AQ_GLASS_JAW
	gain_text = "<span class='danger'>Czujesz, że szczęka ci się chwieje.</span>"
	lose_text = "<span class='notice'>Szczęka znów dobrze się trzyma.</span>"
	medical_record_text = "Pacjenta absurdalnie łatwo znokautować. Nie dopuszczać go w pobliże ringu."

/mob/living/carbon/human/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = FALSE, forced = FALSE)
	. = ..()
	if(. && damagetype == BRUTE && HAS_TRAIT(src, TRAIT_AQ_GLASS_JAW))
		aq_glass_jaw_hit(damage * (100 - blocked) / 100, def_zone)

/// tg glass_jaw punch_out(): a hard blow to the head may knock us out
/mob/living/carbon/human/proc/aq_glass_jaw_hit(damage, def_zone)
	if(isbodypart(def_zone))
		var/obj/item/bodypart/hit_part = def_zone
		def_zone = hit_part.body_zone
	if(!def_zone || check_zone(def_zone) != BODY_ZONE_HEAD || damage < 5)
		return
	if(!prob(CEILING(damage, 1)))
		return
	if(!IsUnconscious() && stat == CONSCIOUS)
		visible_message("<span class='warning'>[src] pada po nokaucie!</span>", "<span class='userdanger'>Tracisz przytomność od ciosu!</span>")
	Unconscious(3 SECONDS)

// ---------------------------------------------------------------------------
// Hemofilia (Yogstation: Hemophiliac, „stała słaba heparyna”). Na naszym krwawieniu z kończyn (AQ#619):
// krew słabo krzepnie, więc rany zamykają się same 5 razy wolniej, a z krwawienia leci półtora raza więcej krwi.

/datum/quirk/hemophilia
	name = "Hemofilia"
	desc = "Twoja krew słabo krzepnie: rany same zamykają się bardzo powoli, a krwawisz z nich mocniej niż inni. Nawet małe skaleczenie może być groźne."
	icon = "band-aid"
	value = -2
	mob_trait = TRAIT_AQ_HEMOPHILIA
	gain_text = "<span class='danger'>Czujesz, że masz rzadką krew.</span>"
	lose_text = "<span class='notice'>Twoja krew znów ma normalną gęstość.</span>"
	medical_record_text = "Krew pacjenta nie krzepnie prawidłowo."

/datum/quirk/hemophilia/add()
	var/mob/living/carbon/human/H = quirk_holder
	H.physiology.bleed_mod *= AQ_HEMOPHILIA_BLEED_MOD

/datum/quirk/hemophilia/remove()
	var/mob/living/carbon/human/H = quirk_holder
	H.physiology?.bleed_mod /= AQ_HEMOPHILIA_BLEED_MOD

/datum/status_effect/bleeding/tick()
	var/base_multiplier = initial(bleed_heal_multiplier)
	bleed_heal_multiplier = HAS_TRAIT(owner, TRAIT_AQ_HEMOPHILIA) ? base_multiplier * AQ_HEMOPHILIA_CLOTTING : base_multiplier
	return ..()

// ---------------------------------------------------------------------------
// Porażenie połowicze (tg: Hemiplegic). Bez wyboru strony w oknie postaci: strona jest losowa.

/datum/brain_trauma/severe/paralysis/aq_hemiplegic
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_ABSOLUTE

/datum/quirk/hemiplegic
	name = "Porażenie połowicze"
	desc = "Połowa twojego ciała nie działa. Nic tego nie naprawi."
	icon = "user-slash"
	value = -3
	gain_text = null // trauma
	lose_text = null
	medical_record_text = "Pacjent ma nieuleczalne upośledzenie funkcji ruchowych połowy ciała."
	/// Porażona strona: "left" albo "right"
	var/side

/datum/quirk/hemiplegic/add()
	side = pick("left", "right")
	apply_side()

/// Nakłada traumę porażenia na wybraną stronę
/datum/quirk/hemiplegic/proc/apply_side()
	medical_record_text = "Pacjent ma nieuleczalne upośledzenie funkcji ruchowych [side == "left" ? "lewej" : "prawej"] połowy ciała."
	var/mob/living/carbon/C = quirk_holder
	C.gain_trauma(new /datum/brain_trauma/severe/paralysis/aq_hemiplegic(side), TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/hemiplegic/remove()
	var/mob/living/carbon/C = quirk_holder
	if(!QDELETED(C))
		C.cure_trauma_type(/datum/brain_trauma/severe/paralysis/aq_hemiplegic, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/hemiplegic/clone_data()
	return side

/// Klon ma porażoną tę samą stronę co oryginał
/datum/quirk/hemiplegic/on_clone(data)
	if(!(data in list("left", "right")) || data == side)
		return
	remove()
	side = data
	apply_side()

// ---------------------------------------------------------------------------
// Alergia pokarmowa (tg: Food Allergy). Bez wyboru alergenu w oknie postaci i bez nieśmiertelnika. tg zaraża
// anafilaksją; u nas każdy kęs alergenu dodaje histaminę (przedawkowanie dusi i rani), epinefryna i difenhydramina ją usuwają.

/datum/quirk/food_allergic
	name = "Alergia pokarmowa"
	desc = "Od dziecka masz alergię na niektóre jedzenie."
	icon = "fish"
	value = -1
	gain_text = "<span class='danger'>Czujesz, że twój układ odpornościowy się zmienia.</span>"
	lose_text = "<span class='notice'>Twój układ odpornościowy wraca do pełnej sprawności.</span>"
	medical_record_text = "Układ odpornościowy pacjenta gwałtownie reaguje na niektóre jedzenie."
	/// Food types that trigger the allergy
	var/target_foodtypes = NONE
	var/allergy_name
	/// Allergen name -> food type (NUTS and SEAFOOD from tg are commented out in our food.dm)
	var/static/list/possible_allergies = list(
		"alkohol" = ALCOHOL,
		"robaki" = BUGS,
		"nabiał" = DAIRY,
		"owoce" = FRUIT,
		"zboża" = GRAIN,
		"mięso" = MEAT,
		"cukier" = SUGAR,
		"warzywa" = VEGETABLES,
	)

/datum/quirk/food_allergic/add()
	if(target_foodtypes == NONE)
		allergy_name = pick(possible_allergies)
		target_foodtypes = possible_allergies[allergy_name]
	medical_record_text = "Układ odpornościowy pacjenta gwałtownie reaguje na: [allergy_name]."
	RegisterSignal(quirk_holder, list(COMSIG_LIVING_EAT_FOOD, COMSIG_AQ_LIVING_DRINK), PROC_REF(on_eat))

/datum/quirk/food_allergic/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_LIVING_EAT_FOOD, COMSIG_AQ_LIVING_DRINK))

/datum/quirk/food_allergic/clone_data()
	return allergy_name

/datum/quirk/food_allergic/on_clone(data)
	if(!(data in possible_allergies))
		return
	allergy_name = data
	target_foodtypes = possible_allergies[allergy_name]
	medical_record_text = "Układ odpornościowy pacjenta gwałtownie reaguje na: [allergy_name]."

/datum/quirk/food_allergic/post_add()
	to_chat(quirk_holder, "<span class='info'>Masz alergię na: [allergy_name]. Uważaj, co jesz!</span>")

/// Picie z napoju też uczula (sygnał jedzenia wysyła tylko gryzienie jedzenia)
/obj/item/reagent_containers/food/drinks/checkLiked(fraction, mob/M)
	. = ..()
	if(isliving(M))
		SEND_SIGNAL(M, COMSIG_AQ_LIVING_DRINK, src, foodtype)

/datum/quirk/food_allergic/proc/on_eat(datum/source, atom/food, foodtypes)
	SIGNAL_HANDLER
	if(!(foodtypes & target_foodtypes))
		return
	var/mob/living/carbon/C = quirk_holder
	if(!C.reagents.has_reagent(/datum/reagent/toxin/histamine))
		to_chat(C, "<span class='warning'>Zaczyna cię swędzieć gardło.</span>")
		SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "allergic_food", /datum/mood_event/aq_allergic_food)
	C.reagents.add_reagent(/datum/reagent/toxin/histamine, 10)

/datum/mood_event/aq_allergic_food
	description = "<span class='warning'>Swędzi mnie gardło.</span>\n"
	mood_change = -2
	timeout = 5 MINUTES

// ---------------------------------------------------------------------------
// Nieczuły na ból (tg: Numb). TRAIT_ANALGESIA wyłącza ból z medycyny (aquila/code/modules/pain/), a z nim
// czerwoną winietę obrażeń. Jak w tg wskaźnik i ludzik zdrowia zawsze pokazują zdrowie (bez hal_screwyhud,
// który zerują inne efekty), więc o ranach dowiadujesz się dopiero od lekarza albo z wyglądu.

/datum/quirk/numb
	name = "Nieczuły na ból"
	desc = "W ogóle nie czujesz bólu."
	icon = "star-of-life"
	value = -1
	mob_trait = TRAIT_ANALGESIA
	gain_text = "<span class='notice'>Czujesz, jak twoje ciało drętwieje.</span>"
	lose_text = "<span class='notice'>Drętwienie ustępuje.</span>"
	medical_record_text = "Pacjent ma wrodzoną niedoczulicę i nie odczuwa bólu."

/mob/living/carbon/human/update_health_hud()
	. = ..()
	if(!client || !hud_used || stat == DEAD || !has_quirk(/datum/quirk/numb))
		return
	if(hud_used.healths)
		hud_used.healths.icon_state = "health0"
	if(hud_used.healthdoll)
		hud_used.healthdoll.cut_overlays()
		for(var/missing_zone in get_missing_limbs()) // brak kończyny widać i tak
			hud_used.healthdoll.add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[missing_zone]6"))

// ---------------------------------------------------------------------------
// Tanie organy (tg: surplus organs) dla Protetycznego organu i Blaszanego drwala. Słabsze i bez wybuchu przy
// wyjmowaniu (tg dangerous_organ_removal); na EMP reagują jak nasze cybernetyczne organy.

/obj/item/organ/heart/cybernetic/aq_surplus
	name = "tanie cybernetyczne serce"
	desc = "Krucha podróbka ludzkiego serca, bardziej przypomina pompę wodną niż prawdziwe serce. Nie ma awaryjnej dawki epinefryny i nie chroni przed EMP."
	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.5
	dose_available = FALSE

/obj/item/organ/lungs/cybernetic/aq_surplus
	name = "tanie cybernetyczne płuca"
	desc = "Dwa kruche, nadmuchiwane worki, które ledwo naśladują ludzkie płuca. Nie chronią przed EMP."
	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.35
	safe_breath_min = 16
	safe_breath_max = 50

/obj/item/organ/liver/cybernetic/aq_surplus
	name = "tania cybernetyczna wątroba"
	desc = "Bardzo tania proteza wątroby, przypomina bardziej filtr do wody niż wątrobę. Krucha, fatalnie filtruje toksyny i źle znosi alkohol. Nie chroni przed EMP."
	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.35
	alcohol_tolerance = ALCOHOL_RATE * 2
	toxTolerance = 1
	toxLethality = LIVER_DEFAULT_TOX_LETHALITY * 1.25

/obj/item/organ/stomach/cybernetic/aq_surplus
	name = "tani cybernetyczny żołądek"
	desc = "Mechaniczny plastikowy owal, w którym zamiast soku żołądkowego jest kwas siarkowy. Bardzo kruchy, boleśnie wolno trawi i nie chroni przed EMP."
	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.35
	metabolism_efficiency = 0.025

/// Organ slot -> zwykły organ człowieka; organ rasy innego typu (płuca plazmaluda, bateria eteryka) zostaje
GLOBAL_LIST_INIT(aq_surplus_plain_organs, list(
	ORGAN_SLOT_HEART = /obj/item/organ/heart,
	ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
	ORGAN_SLOT_LIVER = /obj/item/organ/liver,
	ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
))

/// Organ slot -> surplus organ type, in the tg order
GLOBAL_LIST_INIT(aq_surplus_organs, list(
	ORGAN_SLOT_HEART = /obj/item/organ/heart/cybernetic/aq_surplus,
	ORGAN_SLOT_LUNGS = /obj/item/organ/lungs/cybernetic/aq_surplus,
	ORGAN_SLOT_LIVER = /obj/item/organ/liver/cybernetic/aq_surplus,
	ORGAN_SLOT_STOMACH = /obj/item/organ/stomach/cybernetic/aq_surplus,
))

/// Organ slots of a human that a surplus organ can replace: an organic organ the species really uses
/proc/aq_surplus_organ_slots(mob/living/carbon/human/H)
	. = list()
	for(var/slot in GLOB.aq_surplus_organs)
		var/obj/item/organ/old_organ = H.getorganslot(slot)
		if(!old_organ || old_organ.status != ORGAN_ORGANIC)
			continue
		if(old_organ.type != GLOB.aq_surplus_plain_organs[slot]) // organ właściwy rasie robi coś, czego tani organ nie umie
			continue
		if(slot == ORGAN_SLOT_HEART && ((NOBLOOD in H.dna?.species?.species_traits) || HAS_TRAIT(H, TRAIT_NO_BLOOD)))
			continue
		if(slot == ORGAN_SLOT_LUNGS && HAS_TRAIT(H, TRAIT_NOBREATH))
			continue
		if(slot == ORGAN_SLOT_STOMACH && HAS_TRAIT(H, TRAIT_NOHUNGER))
			continue
		. += slot

/proc/aq_surplus_organ_name(slot)
	switch(slot)
		if(ORGAN_SLOT_HEART)
			return "serce"
		if(ORGAN_SLOT_LUNGS)
			return "płuca"
		if(ORGAN_SLOT_LIVER)
			return "wątroba"
		if(ORGAN_SLOT_STOMACH)
			return "żołądek"

// ---------------------------------------------------------------------------
// Protetyczny organ (tg: Prosthetic Organ). Organ losowy (bez wyboru w oknie postaci); stary organ znika jak przy
// naszej Protezie, więc usunięcie cechy go nie przywraca.

/datum/quirk/prosthetic_organ
	name = "Protetyczny organ"
	desc = "Przez wypadek nie masz jednego z organów. Dlatego masz tanią protezę!"
	icon = "heartbeat"
	value = -1
	medical_record_text = "Podczas badania stwierdzono u pacjenta tani protetyczny organ."
	var/slot_string

/datum/quirk/prosthetic_organ/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/list/slots = aq_surplus_organ_slots(H)
	if(!length(slots))
		return
	var/slot = pick(slots)
	var/organ_type = GLOB.aq_surplus_organs[slot]
	var/obj/item/organ/prosthetic = new organ_type()
	prosthetic.Insert(H, TRUE, FALSE)
	slot_string = aq_surplus_organ_name(slot)
	medical_record_text = "Podczas badania stwierdzono u pacjenta tani protetyczny organ ([slot_string])."

/datum/quirk/prosthetic_organ/post_add()
	if(slot_string)
		to_chat(quirk_holder, "<span class='boldannounce'>Twój organ ([slot_string]) został zastąpiony tanią protezą. Jest słaby i bardzo niestabilny, a każdy impuls EMP może go całkowicie wyłączyć.</span>")

// ---------------------------------------------------------------------------
// Blaszany drwal (tg: Tin Man): wszystkie organy, które da się wymienić, są tanimi protezami.

/datum/quirk/tin_man
	name = "Blaszany drwal"
	desc = "Ups! Same protezy! Przez wyjątkowo okrutną karę losu większość twoich narządów wewnętrznych zastąpiły tanie protezy."
	icon = "user-cog"
	value = -2
	medical_record_text = "Podczas badania stwierdzono u pacjenta liczne tanie protezy narządów wewnętrznych."

/datum/quirk/tin_man/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	for(var/slot in aq_surplus_organ_slots(H))
		var/organ_type = GLOB.aq_surplus_organs[slot]
		var/obj/item/organ/prosthetic = new organ_type()
		prosthetic.Insert(H, TRUE, FALSE)

/datum/quirk/tin_man/post_add()
	to_chat(quirk_holder, "<span class='boldannounce'>Większość twoich narządów wewnętrznych zastąpiły tanie protezy. Są kruche i łatwo się psują, a każdy impuls EMP może je całkowicie wyłączyć.</span>")

// ---------------------------------------------------------------------------
// Poczwórna amputacja (tg: Quadruple Amputee). Jak nasza Proteza: kończyny wymieniane przy starcie, bez przywracania.

/datum/quirk/quadruple_amputee
	name = "Poczwórna amputacja"
	desc = "Ups! Same protezy! Przez wyjątkowo okrutną karę losu wszystkie twoje kończyny zastąpiły tanie protezy."
	icon = "tg-prosthetic-full"
	value = -2
	medical_record_text = "Podczas badania stwierdzono u pacjenta wyłącznie tanie protezy kończyn."

/datum/quirk/quadruple_amputee/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/static/list/surplus_limbs = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/l_arm/robot/surplus,
		BODY_ZONE_R_ARM = /obj/item/bodypart/r_arm/robot/surplus,
		BODY_ZONE_L_LEG = /obj/item/bodypart/l_leg/robot/surplus,
		BODY_ZONE_R_LEG = /obj/item/bodypart/r_leg/robot/surplus,
	)
	for(var/zone in surplus_limbs)
		var/obj/item/bodypart/old_part = H.get_bodypart(zone)
		if(!old_part)
			continue
		if(old_part.held_index && (zone == BODY_ZONE_L_LEG || zone == BODY_ZONE_R_LEG))
			continue // odnóża Groda to jego druga para rąk, ludzka proteza nogi by ją zabrała
		var/limb_type = surplus_limbs[zone]
		var/obj/item/bodypart/prosthetic = new limb_type(H)
		// Jak w naszej Protezie (NSV13): proteza nogi palcochodnej też jest palcochodna
		if(old_part.bodytype & BODYTYPE_DIGITIGRADE)
			prosthetic.bodytype |= BODYTYPE_DIGITIGRADE
			prosthetic.static_icon = 'nsv13/icons/mob/augmentation/digitigrade_legs.dmi'
			prosthetic.limb_id = "digitigrade"
		prosthetic.replace_limb(H)
		qdel(old_part)
	H.regenerate_icons()

/datum/quirk/quadruple_amputee/post_add()
	to_chat(quirk_holder, "<span class='boldannounce'>Wszystkie twoje kończyny zastąpiły tanie protezy. Są kruche i łatwo odpadają pod obciążeniem. Naprawia się je spawarką i przewodami, a nie szwami i maściami.</span>")

// ---------------------------------------------------------------------------
// Wymazująca choroba przewlekła (tg: Eradicative Chronic Illness). Choroba, sansufentanyl, pigułki i skrzynia
// w zaopatrzeniu z tg. Choroba nie zaraża i nie da się jej wyleczyć; sansufentanyl cofa jej stadia.

/datum/disease/aq_chronic_illness
	form = "Schorzenie"
	name = "Dziedziczna choroba rozmaitościowa"
	max_stages = 5
	spread_text = "Brak"
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	disease_flags = NONE
	infectable_biotypes = list(MOB_ORGANIC, MOB_INORGANIC, MOB_ROBOTIC, MOB_UNDEAD) // tg: MOB_MINERAL, u nas pusty stub
	process_dead = TRUE
	stage_prob = 0.5 // tg: 0,25 na sekundę, nasz Life co 2 s
	cure_text = "Łagodzi ją sansufentanyl."
	cures = list(/datum/reagent/medicine/sansufentanyl)
	infectivity = 0
	agent = "Splątanie kwantowe"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Choroba odkryta w laboratorium Interdyne, wywołana technologią korekty strumienia czasu. Jest całkowicie nieuleczalna, choć leczenie może cofać jej postęp, i nie zaraża. Nieleczona daje zawroty głowy, nudności, kołatanie serca, a w końcowym stadium śmierć."
	danger = DISEASE_DANGEROUS
	bypasses_immunity = TRUE

// Pełny stage_act zamiast rodzica: bez CURABLE rodzic nie cofa stadiów, a sansufentanyl ma je cofać (tg CHRONIC)
/datum/disease/aq_chronic_illness/stage_act()
	if(!affected_mob || affected_mob.IsInStasis())
		return
	carrier = FALSE
	if(affected_mob.reagents?.has_reagent(/datum/reagent/medicine/sansufentanyl))
		if(stage > 1 && prob(cure_chance))
			update_stage(stage - 1)
		return
	if(prob(stage_prob))
		update_stage(min(stage + 1, max_stages))
	var/mob/living/carbon/C = affected_mob
	switch(stage)
		if(2)
			if(prob(1))
				to_chat(C, "<span class='warning'>Kręci ci się w głowie.</span>")
				C.confused = max(C.confused, 6)
			if(prob(1))
				to_chat(C, "<span class='notice'>Patrzysz na swoją dłoń. Obraz ci się rozmywa.</span>")
				C.blur_eyes(5)
		if(3)
			if(prob(1))
				to_chat(C, "<span class='danger'>Czujesz bardzo ostry ból w klatce piersiowej!</span>")
				if(prob(45))
					C.vomit(20, TRUE)
			if(prob(1))
				to_chat(C, "<span class='userdanger'>[pick("Czujesz, jak serce ci zwalnia...", "Rozluźniasz się i spowalniasz bicie serca.")]</span>")
				C.adjustStaminaLoss(70)
			if(prob(2))
				to_chat(C, "<span class='danger'>Czujesz brzęczenie w mózgu.</span>")
				SEND_SOUND(C, sound('sound/weapons/flash_ring.ogg'))
			if(prob(1))
				C.adjustBruteLoss(1)
		if(4)
			if(prob(30))
				C.playsound_local(C, 'sound/effects/singlebeat.ogg', 100, FALSE, use_reverb = FALSE)
			if(prob(2))
				to_chat(C, "<span class='danger'>Czujesz potworny ból w klatce piersiowej!</span>")
				if(prob(75))
					C.vomit(45, TRUE)
			if(prob(2))
				C.adjustStaminaLoss(100)
				C.visible_message("<span class='warning'>[C] pada na ziemię!</span>")
				if(prob(30))
					to_chat(C, "<span class='danger'>Mdlejesz, a obraz ci się rozmywa!</span>")
					C.AdjustSleeping(1 SECONDS)
			if(prob(1))
				to_chat(C, "<span class='danger'>[pick("Czujesz, jakby twoje atomy przyspieszały w miejscu.", "Czujesz, jakby coś rozrywało cię na strzępy!")]</span>")
				C.emote("scream")
				C.adjustBruteLoss(10)
		if(5)
			if(prob(50))
				to_chat(C, "<span class='notice'>Czujesz, jak twoje atomy znów się układają. Na razie nic ci nie grozi.</span>")
				update_stage(1)
				return
			to_chat(C, "<span class='boldwarning'>Nie ma dla ciebie miejsca w tej linii czasu.</span>")
			C.adjustStaminaLoss(100, forced = TRUE)
			playsound(C.loc, 'sound/magic/repulse.ogg', 100, FALSE)
			C.emote("scream")
			for(var/mob/living/viewer in viewers(3, C.loc))
				viewer.flash_act()
			new /obj/effect/decal/cleanable/plasma(C.loc)
			new /obj/effect/decal/cleanable/ash(C.loc)
			C.visible_message("<span class='warning'>[C] znika z linii czasu!</span>", "<span class='userdanger'>Zostajesz wyrwany z linii czasu!</span>")
			C.investigate_log("has been dusted / deleted by [name].", INVESTIGATE_DEATHS)
			C.ghostize(FALSE)
			qdel(C)

/datum/reagent/medicine/sansufentanyl
	name = "Sansufentanyl"
	description = "Lek na dziedziczną chorobę rozmaitościową. Przejściowe skutki uboczne: nudności, zawroty głowy, zaburzenia koordynacji."
	color = "#07e4d1"
	chem_flags = CHEMICAL_NOT_SYNTH

/datum/reagent/medicine/sansufentanyl/on_mob_life(mob/living/carbon/M)
	M.confused = min(M.confused + 1, 3)
	M.dizziness = min(M.dizziness + 2, 6)
	M.adjustStaminaLoss(0.5, FALSE)
	if(prob(10))
		to_chat(M, "<span class='warning'>Masz mętlik w głowie i tracisz orientację.</span>")
		if(prob(30))
			SEND_SOUND(M, sound('sound/weapons/flash_ring.ogg'))
	..()
	. = TRUE

/obj/item/reagent_containers/pill/aq_sansufentanyl
	name = "pigułka: sansufentanyl"
	desc = "Lek na dziedziczną chorobę rozmaitościową. Przejściowe skutki uboczne: nudności, zawroty głowy, zaburzenia koordynacji."
	icon_state = "pill_shape_capsule_purple_pink"
	list_reagents = list(/datum/reagent/medicine/sansufentanyl = 5)

/obj/item/storage/pill_bottle/aq_sansufentanyl
	name = "pojemnik z lekiem eksperymentalnym"
	desc = "Pigułki opracowane przez Interdyne Pharmaceuticals. Leczy się nimi dziedziczną chorobę rozmaitościową."

/obj/item/storage/pill_bottle/aq_sansufentanyl/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/pill/aq_sansufentanyl(src)

/datum/supply_pack/medical/aq_experimental_medicine
	name = "Skrzynia leków eksperymentalnych"
	desc = "Zawiera sansufentanyl, lek potrzebny do życia z dziedziczną chorobą rozmaitościową."
	cost = 1000
	contains = list(/obj/item/storage/pill_bottle/aq_sansufentanyl,
					/obj/item/storage/pill_bottle/aq_sansufentanyl)
	crate_name = "skrzynia leków eksperymentalnych"

/datum/quirk/chronic_illness
	name = "Wymazująca choroba przewlekła"
	desc = "Masz anomalną chorobę przewlekłą, którą trzeba stale leczyć, bo inaczej korekta strumienia czasu wymaże cię z istnienia."
	icon = "hourglass-half"
	value = -3
	gain_text = "<span class='danger'>Czujesz, jak powoli znikasz...</span>"
	lose_text = "<span class='notice'>Nagle czujesz się bardziej namacalny.</span>"
	medical_record_text = "Pacjent ma anomalną chorobę przewlekłą, którą trzeba stale leczyć."
	var/where

/datum/quirk/chronic_illness/add()
	quirk_holder.ForceContractDisease(new /datum/disease/aq_chronic_illness(), FALSE, TRUE)

/datum/quirk/chronic_illness/remove()
	for(var/datum/disease/aq_chronic_illness/illness in quirk_holder.diseases)
		illness.cure(FALSE)

/datum/quirk/chronic_illness/on_spawn()
	where = aq_cialo_give_item(new /obj/item/storage/pill_bottle/aq_sansufentanyl(get_turf(quirk_holder)))

/datum/quirk/chronic_illness/post_add()
	if(where)
		to_chat(quirk_holder, "<span class='boldnotice'>Dostajesz lek na swoją chorobę ([where]). Bierz go regularnie, żeby uniknąć powikłań. Więcej zamówisz w zaopatrzeniu.</span>")

// ---------------------------------------------------------------------------
// Niedobór odporności (tg: Immunodeficiency). U nas choroby to system Bee (wirusologia disease2 z Monke dała tylko
// objawy): odporność to zapisane odporności na choroby, sytość, spacyklina i TRAIT_VIRUS_RESISTANCE. Jak w tg choroby
// rozwijają się dwa razy szybciej; dodatkowo zarażenie przez kontakt i powietrze ma dwie próby zamiast jednej.

/datum/quirk/immunodeficiency
	name = "Niedobór odporności"
	desc = "Przez przewlekłą chorobę albo pech w genach twoje ciało jest całodobowym pensjonatem dla bakterii, wirusów i pasożytów. Nawet z przepisanymi lekami na odporność chorujesz ciężej niż inni."
	icon = "biohazard"
	value = -2
	mob_trait = TRAIT_IMMUNODEFICIENCY
	gain_text = "<span class='danger'>Na samą myśl o chorobie dostajesz gorączki.</span>"
	lose_text = "<span class='notice'>Twój układ odpornościowy cudem odzyskuje siły.</span>"
	medical_record_text = "Pacjent cierpi na przewlekły niedobór odporności."

/datum/quirk/immunodeficiency/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/mask/surgical/mask = new(get_turf(H))
	if(!H.equip_to_slot_if_possible(mask, ITEM_SLOT_MASK, disable_warning = TRUE, bypass_equip_delay_self = TRUE))
		aq_cialo_give_item(mask)
	aq_cialo_give_item(new /obj/item/storage/pill_bottle/aq_spaceacillin(get_turf(H)))

/obj/item/reagent_containers/pill/aq_spaceacillin
	name = "pigułka: spacyklina"
	desc = "Wzmacnia odporność i spowalnia rozwój chorób."
	icon_state = "pill_shape_tablet_white_lined"
	list_reagents = list(/datum/reagent/medicine/spaceacillin = 10)

/obj/item/storage/pill_bottle/aq_spaceacillin
	name = "pojemnik z lekami na odporność"
	desc = "Leki wzmacniające odporność, stosowane przy przewlekłym niedoborze odporności."

/obj/item/storage/pill_bottle/aq_spaceacillin/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/aq_spaceacillin(src)

/datum/disease/stage_act()
	. = ..()
	if(QDELETED(src) || !affected_mob || !HAS_TRAIT(affected_mob, TRAIT_IMMUNODEFICIENCY))
		return
	if(carrier || has_cure() || affected_mob.IsInStasis())
		return
	if(prob(stage_prob))
		update_stage(min(stage + 1, max_stages))

/mob/living/carbon/ContactContractDisease(datum/disease/D, target_zone)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_IMMUNODEFICIENCY) && !HasDisease(D))
		. = ..()

/mob/living/carbon/AirborneContractDisease(datum/disease/D, force_spread)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_IMMUNODEFICIENCY) && !HasDisease(D))
		. = ..()

// ---------------------------------------------------------------------------
// Mocny żołądek (tg: Strong Stomach). Wymioty zabierają połowę jedzenia i ogłuszają o połowę krócej, a zakażone
// jedzenie nie zaraża. Jedzenia z podłogi u nas nic nie psuje, więc tej części z tg nie ma.

/datum/quirk/strong_stomach
	name = "Mocny żołądek"
	desc = "Możesz jeść rzeczy, które wypadły na podłogę, bez ryzyka choroby, a wymioty mniej ci szkodzą."
	icon = "grin-beam-sweat"
	value = 1
	mob_trait = TRAIT_STRONG_STOMACH
	gain_text = "<span class='notice'>Czujesz, że dasz radę zjeść wszystko!</span>"
	lose_text = "<span class='danger'>Na widok jedzenia na podłodze robi ci się trochę niedobrze.</span>"
	medical_record_text = "Pacjent ma ponadprzeciętnie silny układ odpornościowy... przynajmniej na zatrucia pokarmowe."

/mob/living/carbon/vomit(lost_nutrition = 10, blood = FALSE, stun = TRUE, distance = 1, message = TRUE, toxic = FALSE)
	if(blood || !HAS_TRAIT(src, TRAIT_STRONG_STOMACH) || HAS_TRAIT(src, TRAIT_NOHUNGER) || HAS_TRAIT(src, TRAIT_NOVOMIT) || !has_mouth())
		return ..()
	var/dry_heave = nutrition < 100
	. = ..(lost_nutrition * 0.5, blood, FALSE, distance, message, toxic)
	if(stun)
		Paralyze(dry_heave ? 15 : 8)
		Knockdown(dry_heave ? 90 : 45)

/datum/component/infective/try_infect_eat(datum/source, mob/living/eater, mob/living/feeder)
	if(HAS_TRAIT(eater, TRAIT_STRONG_STOMACH))
		return
	return ..()

// ---------------------------------------------------------------------------
// Kulawy (tg: Limper). tg: status kulenia spowalnia co drugi krok; u nas spowolnienie ruchu jak przy złamaniu
// z naszych ran (aq_wounds). Laska w ręce znosi kulenie (tg: walking_aid).

/datum/quirk/limper
	name = "Kulawy"
	desc = "Wyraźnie kulejesz, co mocno cię spowalnia. Dobrze, że masz ze sobą laskę."
	icon = "crutch"
	value = -2
	gain_text = "<span class='danger'>Czujesz, że noga ci słabnie.</span>"
	lose_text = "<span class='notice'>Nogi znów są w porządku.</span>"
	medical_record_text = "Pacjent ma osłabioną nogę."
	process = TRUE

/datum/quirk/limper/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/cane/cane = new(get_turf(H))
	if(!H.put_in_hands(cane))
		aq_cialo_give_item(cane)

/datum/quirk/limper/on_process(delta_time)
	var/mob/living/carbon/C = quirk_holder
	var/limping = (C.get_bodypart(BODY_ZONE_L_LEG) || C.get_bodypart(BODY_ZONE_R_LEG)) && !(locate(/obj/item/cane) in C.held_items)
	if(!limping)
		C.remove_movespeed_modifier("aq_limper")
	else if(!C.has_movespeed_modifier("aq_limper"))
		C.add_movespeed_modifier("aq_limper", override = TRUE, multiplicative_slowdown = AQ_LIMPER_SLOWDOWN)

/datum/quirk/limper/remove()
	quirk_holder?.remove_movespeed_modifier("aq_limper")

// ---------------------------------------------------------------------------
// Twarde stopy (Skyrat/Monke: Hardened Soles): bose stopy nie ranią się o odłamki i kolce (caltrop).

/datum/quirk/hardened_soles
	name = "Twarde stopy"
	desc = "Chodzenie boso to dla ciebie nic nowego i nie ponosisz tego przykrych skutków."
	icon = "socks"
	value = 1
	mob_trait = TRAIT_HARD_SOLES
	gain_text = "<span class='notice'>Podłoże nie wydaje się już takie szorstkie pod stopami.</span>"
	lose_text = "<span class='danger'>Zaczynasz czuć każdą nierówność podłoża.</span>"
	medical_record_text = "Stopy pacjenta są odporniejsze na urazy."

/datum/component/caltrop/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(!(flags & CALTROP_BYPASS_SHOES) && HAS_TRAIT(arrived, TRAIT_HARD_SOLES))
		return
	return ..()

// ---------------------------------------------------------------------------
// Wiecznie głodny (Nova: Hungry): głód rośnie dwa razy szybciej.

/datum/quirk/hungry
	name = "Wiecznie głodny"
	desc = "Masz nienasycony apetyt, twój żołądek nie ma dna. Żeby nie chodzić głodnym, musisz jeść o wiele więcej niż inni."
	icon = "hamburger"
	value = -1
	gain_text = "<span class='notice'>Czujesz, że twój żołądek nie ma dna.</span>"
	lose_text = "<span class='notice'>Już nie czujesz, że twój żołądek nie ma dna.</span>"
	medical_record_text = "Pacjent głodnieje o wiele szybciej niż inni."

/datum/quirk/hungry/add()
	var/mob/living/carbon/human/H = quirk_holder
	H.physiology.hunger_mod *= AQ_HUNGRY_MOD

/datum/quirk/hungry/remove()
	var/mob/living/carbon/human/H = quirk_holder
	H.physiology?.hunger_mod /= AQ_HUNGRY_MOD

// ---------------------------------------------------------------------------
// Udawanie śmierci (tg: Death Mimicry): emotka „deathgasp” usypia na 30 s i na ten czas wyglądasz na martwego.

/datum/quirk/death_mimicry
	name = "Udawanie śmierci"
	desc = "Masz opanowaną do perfekcji sztukę udawania własnej śmierci. Ostatnie tchnienie (emotka deathgasp) pozbawia cię przytomności i na chwilę każdy, kto cię obejrzy, uzna, że nie żyjesz."
	icon = "skull-crossbones"
	value = 2
	gain_text = "<span class='notice'>Wiesz, jak przekonująco odegrać własną śmierć.</span>"
	lose_text = "<span class='danger'>Twój talent do dramatycznych scen śmierci przepada.</span>"
	medical_record_text = "Pacjent regularnie udaje zatrzymanie akcji serca, żeby wymigać się od bójek."

/datum/emote/living/deathgasp/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!. || !intentional || !isliving(user)) // prawdziwa śmierć i Głos Boga wołają emotkę same
		return
	var/mob/living/living_user = user
	if(living_user.stat == DEAD || !living_user.has_quirk(/datum/quirk/death_mimicry))
		return
	living_user.Unconscious(30 SECONDS, TRUE, TRUE) // ignore_canstun (człowiek nazywa go inaczej)
	ADD_TRAIT(living_user, TRAIT_FAKEDEATH, AQ_DEATH_MIMICRY_TRAIT)
	addtimer(TRAIT_CALLBACK_REMOVE(living_user, TRAIT_FAKEDEATH, AQ_DEATH_MIMICRY_TRAIT), 30 SECONDS)

#undef AQ_DEATH_MIMICRY_TRAIT
#undef AQ_HEMOPHILIA_CLOTTING
#undef AQ_HEMOPHILIA_BLEED_MOD
#undef AQ_LIMPER_SLOWDOWN
#undef AQ_HUNGRY_MOD
