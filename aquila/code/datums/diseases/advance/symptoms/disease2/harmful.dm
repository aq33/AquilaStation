// AQUILA - szkodliwe i śmiertelne objawy z wirusologii disease2 Monkestation
// (monkestation/code/modules/virology/disease/symtoms/harmful/, deadly/ i restricted/stage1.dm), przerobione na advance disease.

/datum/symptom/arachnogenesis
	name = "Efekt arachnogenezy"
	from_disease2 = TRUE
	desc = "Żołądek nosiciela zaczyna produkować pajączki, które nosiciel wymiotuje. Słabsza wersja wirusa rodzi pajączki, które szybko się rozpadają."
	stealth = -2
	resistance = 1
	stage_speed = 2
	transmission = -1
	level = 8
	severity = 3
	symptom_delay_min = 40
	symptom_delay_max = 80
	prefixes = list("Arachnid ")
	threshold_desc = "<b>Szybkość stadiów 8:</b> pajączki nie rozpadają się po minucie i mogą wyrosnąć."
	/// Czy pajączki przeżywają
	var/stable = FALSE

/datum/symptom/arachnogenesis/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 8)
		stable = TRUE

/datum/symptom/arachnogenesis/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 5)
		return
	var/mob/living/M = A.affected_mob
	playsound(get_turf(M), 'sound/effects/splat.ogg', 50, TRUE)
	var/mob/living/spawned = new /mob/living/simple_animal/hostile/spider/growing/spiderling(get_turf(M))
	M.visible_message("<span class='danger'>[M] wymiotuje żywym pajączkiem!</span>", "<span class='userdanger'>Wymiotujesz żywym pajączkiem!</span>")
	if(!stable)
		addtimer(CALLBACK(src, PROC_REF(kill_mob), spawned), 1 MINUTES)

/datum/symptom/arachnogenesis/proc/kill_mob(mob/living/spawned)
	if(QDELETED(spawned) || spawned.stat == DEAD)
		return
	spawned.visible_message("<span class='warning'>[spawned] rozpada się!</span>")
	spawned.death()

/datum/symptom/minttoxin
	name = "Zespół kreozotowy"
	from_disease2 = TRUE
	desc = "Wirus syntetyzuje w ciele nosiciela „cieniutką miętówkę”: substancję, która miesza w głowie."
	stealth = 1
	resistance = 0
	stage_speed = 1
	transmission = 0
	level = 5
	severity = 2
	symptom_delay_min = 20
	symptom_delay_max = 40
	prefixes = list("Minty ")
	threshold_desc = "<b>Szybkość stadiów 7:</b> więcej substancji naraz."

/datum/symptom/minttoxin/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 7)
		power = 2

/datum/symptom/minttoxin/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 5)
		return
	var/mob/living/M = A.affected_mob
	if(!M.reagents || M.reagents.get_reagent_amount(/datum/reagent/toxin/mindbreaker) >= 5)
		return
	to_chat(M, "<span class='notice'>Czujesz miętową świeżość.</span>")
	M.reagents.add_reagent(/datum/reagent/toxin/mindbreaker, 5 * power)

/datum/symptom/touch_reactive/butterfly_skin
	name = "Pęcherzowe oddzielanie naskórka"
	from_disease2 = TRUE
	desc = "Wirus osłabia skórę nosiciela. Pęka ona przy każdym zderzeniu i dotyku."
	stealth = 1
	resistance = 0
	stage_speed = 0
	transmission = -1
	level = 6
	severity = 3
	required_stage = 4
	prefixes = list("Fragile ")
	threshold_desc = "<b>Szybkość stadiów 8:</b> skóra pęka mocniej."

/datum/symptom/touch_reactive/butterfly_skin/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 8)
		power = 2

/datum/symptom/touch_reactive/butterfly_skin/on_hooked(mob/living/host)
	to_chat(host, "<span class='warning'>Skóra wydaje się krucha.</span>")

/datum/symptom/touch_reactive/butterfly_skin/on_unhooked(mob/living/host)
	to_chat(host, "<span class='notice'>Skóra znów jest wytrzymała!</span>")

/datum/symptom/touch_reactive/butterfly_skin/on_touch(mob/living/host, mob/living/other, we_touched)
	if(!can_touch(other))
		return
	host.apply_damage(5 * power, BRUTE, ran_zone())
	if(we_touched)
		to_chat(host, "<span class='warning'>Wpadasz na [other] i schodzi ci płat skóry!</span>")
	else
		to_chat(host, "<span class='warning'>[other] cię dotyka i schodzi ci płat skóry!</span>")
		to_chat(other, "<span class='danger'>Dotykasz [host] i schodzi z niego płat skóry!</span>")

/datum/symptom/toxins
	name = "Nadkwasota"
	from_disease2 = TRUE
	desc = "Wirus blokuje usuwanie naturalnych toksyn, które gromadzą się w ciele nosiciela."
	stealth = 1
	resistance = 1
	stage_speed = 0
	transmission = 0
	level = 5
	severity = 3
	symptom_delay_min = 5
	symptom_delay_max = 15
	prefixes = list("Acidic ")
	threshold_desc = "<b>Szybkość stadiów 6:</b> więcej toksyn.<br><b>Szybkość stadiów 9:</b> dużo więcej toksyn."
	/// Od którego stadium objaw truje
	var/required_stage = 4
	/// Ile toksyn na jeden punkt siły
	var/toxins_per_power = 2

/datum/symptom/toxins/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 9)
		power = 3
	else if(A.stage_rate >= 6)
		power = 2

/datum/symptom/toxins/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < required_stage)
		return
	A.affected_mob.adjustToxLoss(toxins_per_power * power)

/datum/symptom/toxins/killer
	name = "Zespół toksyfikacji"
	from_disease2 = TRUE
	desc = "Groźniejsza odmiana nadkwasoty: wirus gwałtownie wytwarza toksyny."
	stealth = 0
	resistance = 2
	stage_speed = 1
	transmission = -2
	level = 8
	severity = 5
	prefixes = list("Toxic ")
	threshold_desc = "<b>Szybkość stadiów 6:</b> więcej toksyn.<br><b>Szybkość stadiów 9:</b> dużo więcej toksyn."
	required_stage = 5
	toxins_per_power = 5

/datum/symptom/species_change
	name = "Jaszczurzyca"
	from_disease2 = TRUE
	desc = "Wirus przebudowuje ciało nosiciela w jaszczura. Po wyleczeniu nosiciel wraca do swojej rasy."
	stealth = -2
	resistance = 2
	stage_speed = 1
	transmission = -1
	level = 7
	severity = 3
	symptom_delay_min = 20
	symptom_delay_max = 40
	prefixes = list("Lizard ")
	/// Rasa, w którą zmienia nosiciela
	var/datum/species/new_species = /datum/species/lizard
	/// Rasa nosiciela przed przemianą
	var/datum/species/old_species

/datum/symptom/species_change/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(old_species || A.stage < 5)
		return
	var/mob/living/carbon/human/M = A.affected_mob
	if(!ishuman(M) || !M.dna?.species || istype(M.dna.species, new_species))
		return
	old_species = M.dna.species.type
	M.set_species(new_species)
	to_chat(M, "<span class='userdanger'>Twoje ciało się zmienia!</span>")

/datum/symptom/species_change/End(datum/disease/advance/A)
	if(!..())
		return
	if(!old_species)
		return
	var/mob/living/carbon/human/M = A.affected_mob
	if(ishuman(M) && !QDELETED(M))
		M.set_species(old_species)
	old_species = null

/datum/symptom/species_change/moth
	name = "Ćmienie"
	from_disease2 = TRUE
	desc = "Wirus przebudowuje ciało nosiciela w ćmę. Po wyleczeniu nosiciel wraca do swojej rasy."
	prefixes = list("Moth ")
	new_species = /datum/species/moth

/datum/symptom/teratoma_organs
	name = "Zespół potworniaka narządowego"
	from_disease2 = TRUE
	desc = "Wirus nadprodukuje komórki macierzyste ukierunkowane na tworzenie narządów. Gotowe narządy zostają wypchnięte z ciała, a nosiciel odnosi przy tym obrażenia."
	stealth = 0
	resistance = 1
	stage_speed = 2
	transmission = -2
	level = 6
	severity = 3
	symptom_delay_min = 60
	symptom_delay_max = 120
	prefixes = list("Teratoid ")
	threshold_desc = "<b>Odporność 8:</b> wypychanie narządów prawie nie rani nosiciela."

/datum/symptom/teratoma_organs/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 8)
		power = 0.2

/datum/symptom/teratoma_organs/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 4)
		return
	var/mob/living/carbon/M = A.affected_mob
	if(!iscarbon(M))
		return
	var/list/eligible_organs = list()
	for(var/obj/item/organ/organ as anything in M.internal_organs)
		if(istype(organ, /obj/item/organ/wings) || istype(organ, /obj/item/organ/body_egg) || (organ.organ_flags & ORGAN_SYNTHETIC))
			continue
		eligible_organs |= organ.type
	if(!length(eligible_organs))
		return
	var/organ_type = pick(eligible_organs)
	var/obj/item/organ/spawned_organ = new organ_type(M.drop_location())
	var/damage = 0
	if(ismonkey(M)) // małpy są mniejsze i mają mniej miejsca na ludzkie narządy
		damage += 15 * power
	if(M.getBruteLoss() <= 50)
		damage += 5 * power
	if(damage)
		M.take_overall_damage(damage)
	M.visible_message("<span class='warning'>[spawned_organ] wysuwa się z ciała [M] i spada na ziemię!</span>", "<span class='warning'>[spawned_organ] wysuwa się z twojego ciała i spada na ziemię!</span>")

/datum/symptom/flesh_eating_bones
	name = "Martwicze zapalenie powięzi"
	from_disease2 = TRUE
	desc = "Wirus agresywnie atakuje komórki kości i tkanki: silny ból, obrażenia i krwawienie."
	stealth = -2
	resistance = 1
	stage_speed = 0
	transmission = -2
	level = 8
	severity = 5
	base_message_chance = 50
	symptom_delay_min = 15
	symptom_delay_max = 60
	prefixes = list("Necrotizing ")
	threshold_desc = "<b>Odporność 9:</b> więcej obrażeń, a do tego zmęczenie i krwawienie."

/datum/symptom/flesh_eating_bones/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 9)
		power = 2

/datum/symptom/flesh_eating_bones/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(3)
			if(prob(base_message_chance))
				to_chat(M, "<span class='warning'>[pick("Nagle czujesz ból w całym ciele.", "Na skórze pojawiają się krople krwi.")]</span>")
		if(4, 5)
			to_chat(M, "<span class='userdanger'>[pick("Krzywisz się, gdy ciało ogarnia potworny ból.", "Czujesz, jakby ciało zjadało się od środka.", "TO BOLI.")]</span>")
			var/damage = rand(15, 25) * power
			M.take_overall_damage(damage)
			if(power >= 2)
				M.adjustStaminaLoss(damage)
				M.bleed(5 * power)

/datum/symptom/reverse_pattern
	name = "Zespół odwróconego wzoru"
	from_disease2 = TRUE
	desc = "Wirus atakuje DNA nosiciela i wywołuje gwałtowne mutacje. Podnosi też temperaturę ciała, więc kriokomora przestaje pomagać."
	stealth = -1
	resistance = 2
	stage_speed = 1
	transmission = -2
	level = 9
	severity = 5
	symptom_delay_min = 25
	symptom_delay_max = 50
	prefixes = list("Reversed ")
	threshold_desc = "<b>Szybkość stadiów 8:</b> mutacje są częstsze i mocniejsze."

/datum/symptom/reverse_pattern/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 8)
		power = 2

/datum/symptom/reverse_pattern/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 5)
		return
	var/mob/living/carbon/M = A.affected_mob
	if(!iscarbon(M))
		return
	M.bodytemperature = max(M.bodytemperature, 350)
	scramble_dna(M, TRUE, TRUE, rand(15, 45) * power)
	if(M.getToxLoss() <= 50)
		M.adjustToxLoss(10 * power)

/datum/symptom/rhumba_beat
	name = "Rytm rumby"
	from_disease2 = TRUE
	desc = "Wirus rozkręca w ciele nosiciela nieustępliwy rytm. Najpierw tylko dziwne uczucia i zadyszka, potem gorączka i ogień, a na końcu ciało nie wytrzymuje rytmu i wybucha."
	stealth = -2
	resistance = 1
	stage_speed = 1
	transmission = -3
	level = 9
	severity = 5
	symptom_delay_min = 15
	symptom_delay_max = 30
	prefixes = list("Rhumba ")
	threshold_desc = "<b>Odporność 8:</b> rytm narasta dwa razy szybciej."
	/// Jak mocno rozkręcony jest rytm (1-5)
	var/beat = 1
	/// O ile rośnie rytm przy każdym odpaleniu
	var/beat_step = 0.1

/datum/symptom/rhumba_beat/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 8)
		beat_step = 0.2

/datum/symptom/rhumba_beat/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 5)
		return
	var/mob/living/carbon/M = A.affected_mob
	beat = min(beat + beat_step, 5)
	switch(round(beat))
		if(1, 2)
			if(prob(26))
				M.take_overall_damage(burn = 5)
			if(prob(5))
				to_chat(M, "<span class='danger'>Czujesz się dziwnie...</span>")
		if(3)
			if(prob(10))
				to_chat(M, "<span class='danger'>[pick("Masz ochotę zatańczyć...", "Czujesz, że musisz zrobić czik-cziki-bum...")]</span>")
			else if(prob(10))
				M.emote("gasp")
		if(4)
			if(prob(10))
				if(prob(50))
					M.adjust_fire_stacks(2)
					M.ignite_mob()
				else
					M.emote("gasp")
					to_chat(M, "<span class='danger'>Czujesz w środku palący rytm...</span>")
		if(5)
			to_chat(M, "<span class='danger'>Twoje ciało nie jest w stanie powstrzymać rytmu rumby...</span>")
			if(prob(29))
				explosion(get_turf(M), devastation_range = -1, heavy_impact_range = -1, light_impact_range = 2, flash_range = 3, adminlog = FALSE, flame_range = 2)
				beat = max(beat - 3, 1)

/datum/symptom/anxiety
	name = "Silny lęk"
	from_disease2 = TRUE
	desc = "Wirus rozregulowuje ośrodek strachu. Nosiciel ma napady paniki, a w ostatnim stadium wykrztusza motyle."
	stealth = 1
	resistance = 0
	stage_speed = 1
	transmission = 0
	level = 4
	severity = 2
	symptom_delay_min = 15
	symptom_delay_max = 30
	prefixes = list("Anxious ")
	threshold_desc = "<b>Szybkość stadiów 7:</b> pełne napady paniki z drżeniem i motylami."

/datum/symptom/anxiety/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 7)
		power = 2

/datum/symptom/anxiety/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	if(A.stage < 4)
		if(prob(base_message_chance))
			to_chat(M, "<span class='notice'>[pick("Czujesz niepokój.", "Żołądek ci się ściska.")]</span>")
		return
	if(prob(20))
		to_chat(M, "<span class='warning'>[pick("Ogarnia cię panika.", "Czujesz motyle w brzuchu.")]</span>")
	if(power < 2)
		return
	if(prob(10))
		M.visible_message("<span class='danger'>[M] miota się w panice.</span>", "<span class='userdanger'>Masz atak paniki!</span>")
		M.confused += rand(6, 8)
		M.Jitter(rand(12, 16))
	if(iscarbon(M) && prob(5))
		M.visible_message("<span class='danger'>[M] wykrztusza motyle!</span>", "<span class='userdanger'>Wykrztuszasz motyle!</span>")
		new /mob/living/basic/butterfly(get_turf(M))
		new /mob/living/basic/butterfly(get_turf(M))
