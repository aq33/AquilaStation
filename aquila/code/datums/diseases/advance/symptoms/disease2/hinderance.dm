// AQUILA - utrudniające objawy z wirusologii disease2 Monkestation
// (monkestation/code/modules/virology/disease/symtoms/hinderance/), przerobione na advance disease.

/datum/symptom/topographic_confusion
	name = "Kretynizm topograficzny"
	from_disease2 = TRUE
	desc = "Wirus atakuje zdolność odróżniania lewej strony od prawej. Nosiciel chodzi nie tam, gdzie chce."
	stealth = 1
	resistance = 1
	stage_speed = 0
	transmission = 0
	level = 4
	severity = 2
	symptom_delay_min = 10
	symptom_delay_max = 30
	prefixes = list("Lost ")
	threshold_desc = "<b>Szybkość stadiów 7:</b> dłuższe zagubienie."

/datum/symptom/topographic_confusion/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 7)
		power = 3

/datum/symptom/topographic_confusion/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 4)
		return
	var/mob/living/M = A.affected_mob
	to_chat(M, "<span class='warning'>Nagle nie umiesz odróżnić lewej strony od prawej!</span>")
	M.confused = min(M.confused + 5 * power, 20)

/datum/symptom/hemoptysis
	name = "Krwioplucie"
	from_disease2 = TRUE
	desc = "Nosiciel czuje pieczenie w gardle, a po chwili wymiotuje krwią."
	stealth = 0
	resistance = 2
	stage_speed = 0
	transmission = 2
	level = 5
	severity = 2
	symptom_delay_min = 30
	symptom_delay_max = 60
	prefixes = list("Bleeding ")
	threshold_desc = "<b>Odporność 7:</b> więcej krwi."
	/// Czy właśnie trwa atak
	var/active = FALSE

/datum/symptom/hemoptysis/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 7)
		power = 2

/datum/symptom/hemoptysis/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 3 || active)
		return
	var/mob/living/carbon/M = A.affected_mob
	if(!ishuman(M))
		return
	active = TRUE
	to_chat(M, "<span class='warning'>Czujesz pieczenie w gardle.</span>")
	addtimer(CALLBACK(src, PROC_REF(pain), M), 10 SECONDS)

/datum/symptom/hemoptysis/proc/pain(mob/living/carbon/M)
	if(QDELETED(M))
		active = FALSE
		return
	to_chat(M, "<span class='danger'>Gardło przeszywa cię potwornym bólem!</span>")
	addtimer(CALLBACK(src, PROC_REF(cough_blood), M), 10 SECONDS)

/datum/symptom/hemoptysis/proc/cough_blood(mob/living/carbon/M)
	active = FALSE
	if(QDELETED(M))
		return
	M.vomit(10 * power, TRUE)

/datum/symptom/elvis
	name = "Elwizm"
	from_disease2 = TRUE
	desc = "Robi z nosiciela króla rock and rolla: fryzura, baki, kołysanie biodrami i cytaty z piosenek."
	stealth = -2
	resistance = 1
	stage_speed = 1
	transmission = 1
	level = 4
	severity = 1
	symptom_delay_min = 15
	symptom_delay_max = 35
	prefixes = list("Rock'n'Roll ")
	/// Czy nosiciel dostał już mutację Elvisa
	var/mutated = FALSE

/datum/symptom/elvis/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 4)
		return
	var/mob/living/carbon/human/M = A.affected_mob
	if(!ishuman(M))
		return
	if(!mutated && M.dna)
		M.dna.add_mutation(/datum/mutation/elvis, MUT_OTHER)
		mutated = TRUE
	M.confused += 1
	if(prob(50))
		M.say(pick("Uh HUH!", "Dziękuję, dziękuję bardzo...", "Jestem tylko psem gończym!", "Kołysz się nisko, słodki rydwanie!"), forced = "elwizm")
	else
		M.visible_message("<span class='notice'>[M] [pick("wykrzywia wargę!", "kręci biodrami!", "wyrzuca biodra do przodu!")]</span>")
	addtimer(CALLBACK(src, PROC_REF(set_hairstyle), M), 5 SECONDS, TIMER_UNIQUE)

/datum/symptom/elvis/proc/set_hairstyle(mob/living/carbon/human/M)
	if(QDELETED(src) || QDELETED(M))
		return
	if(M.hair_style == "Pompadour (Big)" && M.facial_hair_style == "Sideburns (Elvis)")
		return
	M.hair_style = "Pompadour (Big)"
	M.hair_color = "242424"
	M.facial_hair_style = "Sideburns (Elvis)"
	M.facial_hair_color = "242424"
	M.update_hair()

/datum/symptom/elvis/End(datum/disease/advance/A)
	if(!..())
		return
	if(mutated)
		A.affected_mob.dna?.remove_mutation(/datum/mutation/elvis)
		mutated = FALSE

/datum/symptom/famine
	name = "Głodowa emanacja"
	from_disease2 = TRUE
	desc = "Nosiciel emituje pole, które zabija rośliny wokół niego. Zabójcze dla ras wywodzących się od roślin."
	stealth = 0
	resistance = 2
	stage_speed = -1
	transmission = 1
	level = 5
	severity = 2
	symptom_delay_min = 20
	symptom_delay_max = 40
	prefixes = list("Withering ")
	threshold_desc = "<b>Transmisja 6:</b> większy zasięg.<br><b>Szybkość stadiów 8:</b> większe obrażenia dla roślinnych ras."
	/// Zasięg gnicia plonów
	var/rot_range = 2
	/// Obrażenia toksyczne dla roślinnych ras
	var/plant_damage = 5

/datum/symptom/famine/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= 6)
		rot_range = 4
	if(A.stage_rate >= 8)
		plant_damage = 15

/datum/symptom/famine/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 3)
		return
	var/mob/living/M = A.affected_mob
	if(ispodperson(M))
		M.adjustToxLoss(plant_damage)
	for(var/obj/item/food/grown/crop in range(rot_range, M))
		crop.visible_message("<span class='warning'>[crop] gnije w zastraszającym tempie!</span>")
		new /obj/item/food/badrecipe(get_turf(crop))
		qdel(crop)
		if(prob(30))
			break

/datum/symptom/fragile_bones
	name = "Zespół kruchej osoby"
	from_disease2 = TRUE
	desc = "Wirus osłabia budowę ciała. Każda część ciała wytrzymuje coraz mniej obrażeń."
	stealth = 2
	resistance = 1
	stage_speed = -1
	transmission = -1
	level = 6
	severity = 3
	symptom_delay_min = 30
	symptom_delay_max = 60
	prefixes = list("Brittle ")
	threshold_desc = "<b>Szybkość stadiów 8:</b> ciało słabnie szybciej."
	/// O ile spada wytrzymałość części ciała przy każdym odpaleniu
	var/weaken_step = 5
	/// O ile w sumie osłabiono każdą część ciała
	var/list/weakened = list()

/datum/symptom/fragile_bones/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 8)
		weaken_step = 10

/datum/symptom/fragile_bones/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 5)
		return
	var/mob/living/carbon/M = A.affected_mob
	if(!ishuman(M))
		return
	for(var/obj/item/bodypart/part as anything in M.bodyparts)
		var/already = weakened[part] || 0
		if(already >= 30) // u Monke spadało bez końca, tu najwyżej o 30
			continue
		var/step = min(weaken_step, part.max_damage - 1)
		if(step <= 0)
			continue
		part.max_damage -= step
		weakened[part] = already + step
	if(prob(30))
		to_chat(M, "<span class='warning'>Czujesz, jak kości robią się kruche.</span>")

/datum/symptom/fragile_bones/End(datum/disease/advance/A)
	if(!..())
		return
	for(var/obj/item/bodypart/part as anything in weakened)
		if(!QDELETED(part))
			part.max_damage += weakened[part]
	weakened.Cut()

/datum/symptom/gregarious
	name = "Przymus towarzyski"
	from_disease2 = TRUE
	desc = "Wirus zagnieżdża się w ośrodkach społecznych mózgu: nagradza nosiciela za przebywanie w tłumie potencjalnych ofiar i karze za samotność."
	stealth = -1
	resistance = 1
	stage_speed = 0
	transmission = 4
	level = 6
	severity = 3
	symptom_delay_min = 15
	symptom_delay_max = 30
	prefixes = list("Social ")
	threshold_desc = "<b>Transmisja 8:</b> wymaga więcej osób w pobliżu, ale też mocniej nagradza i karze."
	/// Ilu ludzi musi być w pobliżu
	var/needed_company = 1
	/// Ilu ludzi najwyżej będzie chciał wirus
	var/max_company = 3

/datum/symptom/gregarious/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= 8)
		max_company = 4
		power = 2

/datum/symptom/gregarious/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 5)
		return
	var/mob/living/carbon/M = A.affected_mob
	var/others_count = 0
	for(var/mob/living/carbon/other in oview(5, M))
		others_count++
	if(others_count >= needed_company)
		to_chat(M, "<span class='notice'>Przyjazne uczucie cieszy się, że wokół jest tyle osób - na razie.</span>")
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -needed_company)
		M.reagents?.add_reagent(/datum/reagent/drug/happiness, needed_company * power)
		needed_company = min(needed_company + 1, max_company) // wirus robi się zachłanny
	else
		to_chat(M, "<span class='warning'>Wrogie uczucie kłuje cię w mózg... chce więcej żywych wokół ciebie.</span>")
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, needed_company * power)
		M.Paralyze(needed_company * power * 10)
		needed_company = max(needed_company - 1, 1) // wirus łagodnieje

/datum/symptom/horsethroat
	name = "Końskie gardło"
	from_disease2 = TRUE
	desc = "Na twarzy nosiciela wyrasta końska maska, a on sam rży zamiast mówić."
	stealth = -3
	resistance = 1
	stage_speed = 2
	transmission = 1
	level = 5
	severity = 2
	symptom_delay_min = 20
	symptom_delay_max = 40
	prefixes = list("Equine ")

/datum/symptom/horsethroat/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 4)
		return
	var/mob/living/carbon/human/M = A.affected_mob
	M.say(pick("IIIHAHA!", "Iihaha!", "Iihaha.", "Iihaha?", "Iihaha!!", "Iihaha?!", "Iihaha..."), forced = "końskie gardło")
	if(!ishuman(M) || istype(M.wear_mask, /obj/item/clothing/mask/horsehead))
		return
	if(M.wear_mask)
		M.dropItemToGround(M.wear_mask, TRUE)
	var/obj/item/clothing/mask/horsehead/magichead = new
	if(M.equip_to_slot_if_possible(magichead, ITEM_SLOT_MASK, disable_warning = TRUE))
		to_chat(M, "<span class='warning'>Czujesz się trochę jak koń!</span>")
	else
		qdel(magichead)

/datum/symptom/shakey
	name = "Zespół trzęsącego się świata"
	from_disease2 = TRUE
	desc = "Wirus atakuje układ ruchowy i wywołuje zawroty. Nosicielowi trzęsie się obraz."
	stealth = 1
	resistance = 0
	stage_speed = 1
	transmission = 0
	level = 3
	severity = 1
	symptom_delay_min = 10
	symptom_delay_max = 25
	prefixes = list("Shaking ")
	threshold_desc = "<b>Szybkość stadiów 6:</b> mocniejsze wstrząsy.<br><b>Szybkość stadiów 9:</b> bardzo mocne wstrząsy."

/datum/symptom/shakey/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 9)
		power = 3
	else if(A.stage_rate >= 6)
		power = 2

/datum/symptom/shakey/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 4)
		return
	shake_camera(A.affected_mob, 5 * power, power)

/// Objaw reagujący na dotyk: zderzenie albo dotknięcie ręką nosiciela
/datum/symptom/touch_reactive
	level = -1
	symptom_delay_min = 10
	symptom_delay_max = 20
	/// Od którego stadium objaw działa
	var/required_stage = 3
	/// Czy sygnały są podpięte
	var/hooked = FALSE

/datum/symptom/touch_reactive/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(hooked || A.stage < required_stage)
		return
	var/mob/living/M = A.affected_mob
	RegisterSignal(M, COMSIG_MOVABLE_BUMP, PROC_REF(on_bump))
	RegisterSignal(M, COMSIG_ATOM_BUMPED, PROC_REF(on_bumped))
	RegisterSignal(M, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_hand))
	hooked = TRUE
	on_hooked(M)

/datum/symptom/touch_reactive/End(datum/disease/advance/A)
	if(!..())
		return
	if(!hooked)
		return
	UnregisterSignal(A.affected_mob, list(COMSIG_MOVABLE_BUMP, COMSIG_ATOM_BUMPED, COMSIG_ATOM_ATTACK_HAND))
	hooked = FALSE
	on_unhooked(A.affected_mob)

/datum/symptom/touch_reactive/proc/on_bump(mob/living/source, atom/bumped)
	SIGNAL_HANDLER
	if(isliving(bumped))
		on_touch(source, bumped, TRUE)

/datum/symptom/touch_reactive/proc/on_bumped(mob/living/source, atom/movable/bumper)
	SIGNAL_HANDLER
	if(isliving(bumper))
		on_touch(source, bumper, FALSE)

/datum/symptom/touch_reactive/proc/on_hand(mob/living/source, mob/user)
	SIGNAL_HANDLER
	if(isliving(user) && user != source)
		on_touch(source, user, FALSE)

/// Nosiciel dotknął kogoś (we_touched) albo ktoś dotknął nosiciela
/datum/symptom/touch_reactive/proc/on_touch(mob/living/host, mob/living/other, we_touched)
	return

/datum/symptom/touch_reactive/proc/on_hooked(mob/living/host)
	return

/datum/symptom/touch_reactive/proc/on_unhooked(mob/living/host)
	return

/datum/symptom/touch_reactive/spiky_skin
	name = "Rogowacenie kolczaste"
	from_disease2 = TRUE
	desc = "Na skórze nosiciela wyrastają kolce z keratyny, które ranią każdego, kto na niego wpadnie albo go dotknie."
	stealth = -1
	resistance = 3
	stage_speed = -1
	transmission = -1
	level = 6
	severity = 1
	required_stage = 3
	prefixes = list("Spiked ")
	threshold_desc = "<b>Odporność 9:</b> dłuższe, groźniejsze kolce."
	/// Obrażenia od kolców
	var/spike_damage = 4

/datum/symptom/touch_reactive/spiky_skin/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 9)
		spike_damage = 8

/datum/symptom/touch_reactive/spiky_skin/on_hooked(mob/living/host)
	to_chat(host, "<span class='warning'>Skóra robi się kłująca.</span>")

/datum/symptom/touch_reactive/spiky_skin/on_unhooked(mob/living/host)
	to_chat(host, "<span class='notice'>Skóra znów jest gładka!</span>")

/datum/symptom/touch_reactive/spiky_skin/on_touch(mob/living/host, mob/living/other, we_touched)
	if(issilicon(other))
		return
	other.apply_damage(spike_damage, BRUTE, ran_zone())
	if(we_touched)
		to_chat(host, "<span class='warning'>Wpadasz na [other], a twoje kolce wbijają się w ciało!</span>")
	else
		to_chat(host, "<span class='warning'>[other] cię dotyka, a twoje kolce wbijają się w ciało!</span>")
		to_chat(other, "<span class='danger'>Dotykasz [host], a kolce wbijają ci się w ciało!</span>")
	log_combat(host, other, "zranił kolcami (Rogowacenie kolczaste)")
