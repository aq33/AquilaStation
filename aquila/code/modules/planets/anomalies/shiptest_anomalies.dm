// AQUILA - anomalie planetarne Shiptesta bez odpowiednika u nas: tętno, iskrząca, fontanna, widmowa, topiąca
// i transfuzyjna. Port z Shiptesta (code/game/objects/effects/anomalies/anomalies_heartbeat.dm, anomalies_sparkler.dm,
// anomalies_veins.dm, anomalies_phantom.dm, anomalies_melter.dm, anomalies_transfusion.dm, rdzenie
// z code/modules/assembly/anomalies.dm, licencja AGPLv3; sprite'y anomalii z Shiptesta, CC BY-SA 3.0).
// Wspólne różnice względem Shiptesta:
// - u nas bazowa anomalia nie ma pulse_delay/pulse_cooldown/effectrange, więc każda je deklaruje (jak dusza plazmy);
// - rdzenie bez drugiego kodu (code_b) i wybuchu rdzenia, a mielone dają tylko odczynniki, które u nas istnieją;
// - rdzenie mają ogólny sprite rdzenia (jak w Shiptest) zabarwiony kolorem anomalii;
// - promieniowanie przez nasz radiation_pulse (zasięg, próg izolacji, siła w %), a siła Shiptesta trafia
//   do kolektorów promieniowania (collector_power);
// - krew zabierana i oddawana wprost przez blood_volume (u nas bleed() to krwawienie na tyknięcie, a nie ilość krwi).

/// Rdzenie nowych anomalii: ogólny sprite rdzenia w kolorze anomalii
/obj/item/assembly/signaler/anomaly/heartbeat
	name = "\improper rdzeń anomalii tętna"
	desc = "Zneutralizowany rdzeń anomalii tętna. Po jego powłoce przebiegają fale ciepła. Pewnie przydałby się do badań."
	color = "#7cd67c"

/obj/item/assembly/signaler/anomaly/sparkler
	name = "\improper rdzeń anomalii iskrzącej"
	desc = "Zneutralizowany rdzeń anomalii iskrzącej. Odskakują od niego drobne iskry. Pewnie przydałby się do badań."
	color = "#ffe27a"
	grind_results = list(/datum/reagent/teslium = 10)

/obj/item/assembly/signaler/anomaly/veins
	name = "\improper rdzeń anomalii fontanny"
	desc = "Zneutralizowany rdzeń anomalii fontanny. Jest śliski jak jelito. Pewnie przydałby się do badań."
	color = "#b05ad0"

/obj/item/assembly/signaler/anomaly/veins/Initialize(mapload)
	. = ..()
	grind_results = list(/datum/reagent/medicine/strange_reagent = rand(10, 20))

/obj/item/assembly/signaler/anomaly/phantom
	name = "\improper rdzeń anomalii widmowej"
	desc = "Zneutralizowany rdzeń anomalii widmowej. Cicho krzyczy. Pewnie przydałby się do badań."
	color = "#9aa0b8"
	grind_results = list(/datum/reagent/blood = 20)

/obj/item/assembly/signaler/anomaly/melter
	name = "\improper rdzeń anomalii topiącej"
	desc = "Zneutralizowany rdzeń anomalii topiącej. Syczy i trzeszczy. Pewnie przydałby się do badań."
	icon = 'aquila/icons/obj/anomaly_cores.dmi'
	icon_state = "pyro core"
	color = "#8cff6a"
	grind_results = list(/datum/reagent/toxin/acid/fluacid = 30)

/obj/item/assembly/signaler/anomaly/transfusion
	name = "\improper rdzeń anomalii transfuzyjnej"
	desc = "Zneutralizowany rdzeń anomalii transfuzyjnej. Z pojemnika powoli sączy się szkarłat. Pewnie przydałby się do badań."
	icon = 'aquila/icons/obj/anomaly_cores.dmi'
	icon_state = "pyro core"
	color = "#d03030"
	grind_results = list(/datum/reagent/blood = 35)
	/// Krew zebrana przez anomalię i ile jej się zmieści, zanim anomalia jest „syta”
	var/blood_stored = 0
	var/blood_max

/obj/item/assembly/signaler/anomaly/transfusion/Initialize(mapload)
	. = ..()
	blood_max = rand(400, 1200)

/// Czy można człowiekowi zabrać albo dać krew
/proc/anomaly_can_touch_blood(mob/living/carbon/victim)
	if(!victim.blood_volume || HAS_TRAIT(victim, TRAIT_NO_BLOOD))
		return FALSE
	if(ishuman(victim))
		var/mob/living/carbon/human/human_victim = victim
		if(NOBLOOD in human_victim.dna?.species.species_traits)
			return FALSE
	return TRUE

// ---------------------------------------------------------------------------------------------------------------
// Tętno: co kilka sekund puls promieniowania wokół siebie, rzadziej w losowym miejscu obok z oparzeniami

/obj/effect/anomaly/heartbeat
	name = "anomalia tętna"
	desc = "Pulsujący wierzchołek, który szerzy wokół siebie raka."
	icon = 'aquila/icons/planets/anomalies.dmi'
	icon_state = "heartbeat"
	density = TRUE
	light_color = LIGHT_COLOR_GREEN
	aSignal = /obj/item/assembly/signaler/anomaly/heartbeat
	var/effectrange = 3
	var/pulse_delay = 6 SECONDS
	COOLDOWN_DECLARE(pulse_cooldown)
	COOLDOWN_DECLARE(pulse_secondary_cooldown)

/obj/effect/anomaly/heartbeat/Initialize(mapload, new_lifespan)
	. = ..()
	pulse_delay = rand(pulse_delay * 0.5, pulse_delay * 1.5)

/obj/effect/anomaly/heartbeat/anomalyEffect(delta_time)
	..()
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_delay)
	playsound(src, 'sound/health/slowbeat.ogg', 100)
	radiation_pulse(src, max_range = 2, threshold = RAD_LIGHT_INSULATION, intensity = 10, collector_power = 500)
	if(!COOLDOWN_FINISHED(src, pulse_secondary_cooldown))
		return
	COOLDOWN_START(src, pulse_secondary_cooldown, pulse_delay * 4)
	var/turf/spot = random_spot()
	if(!spot)
		return
	playsound(spot, 'sound/health/slowbeat.ogg', 100)
	radiation_pulse(spot, max_range = effectrange, threshold = RAD_LIGHT_INSULATION, intensity = 5, collector_power = 200)
	for(var/mob/living/carbon/nearby in range(effectrange, spot))
		nearby.apply_damage(10, BURN)
		to_chat(nearby, "<span class='warning'>Na twoim ciele otwierają się oparzenia popromienne.</span>")

/obj/effect/anomaly/heartbeat/Bumped(atom/movable/AM)
	var/turf/spot = random_spot()
	if(!spot)
		return
	playsound(spot, 'sound/health/slowbeat.ogg', 100)
	radiation_pulse(spot, max_range = effectrange, threshold = RAD_LIGHT_INSULATION, intensity = 5, collector_power = 200)

/obj/effect/anomaly/heartbeat/proc/random_spot()
	return locate(rand(x - effectrange, x + effectrange), rand(y - effectrange, y + effectrange), z)

/obj/effect/anomaly/heartbeat/detonate()
	radiation_pulse(src, max_range = 6, threshold = RAD_HEAVY_INSULATION, intensity = 50, collector_power = 5000)
	playsound(src, 'sound/health/fastbeat.ogg', 100)

/obj/effect/anomaly/heartbeat/planetary
	immortal = TRUE
	immobile = TRUE
	core_anomaly_type = /obj/effect/anomaly/heartbeat

// ---------------------------------------------------------------------------------------------------------------
// Iskrząca: sypie iskrami wokół, razi prądem przy dotknięciu

/obj/effect/anomaly/sparkler
	name = "anomalia iskrząca"
	desc = "Chmara migoczących iskier, które latają tam i z powrotem. Próbują się rozprzestrzenić, ale im się nie udaje."
	icon = 'aquila/icons/planets/anomalies.dmi'
	icon_state = "sparkler"
	density = TRUE
	aSignal = /obj/item/assembly/signaler/anomaly/sparkler
	var/effectrange = 4
	var/pulse_delay = 1 SECONDS
	var/secondary_pulse_delay = 5 SECONDS
	COOLDOWN_DECLARE(pulse_cooldown)
	COOLDOWN_DECLARE(pulse_secondary_cooldown)

/obj/effect/anomaly/sparkler/anomalyEffect(delta_time)
	..()
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_delay)
	sparkle()

/obj/effect/anomaly/sparkler/proc/sparkle()
	var/turf/spot = locate(rand(x - effectrange, x + effectrange), rand(y - effectrange, y + effectrange), z)
	if(spot)
		new /obj/effect/particle_effect/sparks(spot)

/obj/effect/anomaly/sparkler/Bumped(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/victim = AM
		victim.electrocute_act(20, name, safety = TRUE)
	if(!COOLDOWN_FINISHED(src, pulse_secondary_cooldown))
		return
	COOLDOWN_START(src, pulse_secondary_cooldown, secondary_pulse_delay)
	tesla_zap(src, 2, 5000, TESLA_FUSION_FLAGS)

/obj/effect/anomaly/sparkler/detonate()
	for(var/i in 1 to 6)
		tesla_zap(src, 3, 10000, TESLA_DEFAULT_FLAGS)
		sparkle()
		sparkle()
		sparkle()

/obj/effect/anomaly/sparkler/planetary
	immortal = TRUE
	immobile = TRUE
	core_anomaly_type = /obj/effect/anomaly/sparkler

// ---------------------------------------------------------------------------------------------------------------
// Fontanna: wysysa krew z ludzi bez dobrego pancerza, przy dotknięciu rozrzuca wnętrzności

/obj/effect/anomaly/veins
	name = "anomalia fontanny"
	desc = "Pulsujące fioletowe żyły, odsłonięta tętnica świata. Coś z niej wycieka."
	icon = 'aquila/icons/planets/anomalies.dmi'
	icon_state = "veins"
	density = TRUE
	aSignal = /obj/item/assembly/signaler/anomaly/veins
	var/effectrange = 3
	var/pulse_delay = 4 SECONDS
	COOLDOWN_DECLARE(pulse_cooldown)
	COOLDOWN_DECLARE(pulse_secondary_cooldown)

/obj/effect/anomaly/veins/Initialize(mapload, new_lifespan)
	. = ..()
	pulse_delay = rand(pulse_delay * 0.5, pulse_delay * 1.5)

/obj/effect/anomaly/veins/anomalyEffect(delta_time)
	..()
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_delay)
	drain_blood()

/obj/effect/anomaly/veins/proc/drain_blood()
	for(var/mob/living/carbon/suckee in range(effectrange, src))
		if(suckee.getarmor(null, "melee") > 40)
			continue
		suckee.bleed(20)
		suckee.apply_damage(5, BRUTE)
		visible_message("<span class='warning'>Krew zaczyna odpływać z [suckee] w stronę [src]!</span>")

/obj/effect/anomaly/veins/Bumped(atom/movable/AM)
	if(!COOLDOWN_FINISHED(src, pulse_secondary_cooldown))
		return
	COOLDOWN_START(src, pulse_secondary_cooldown, 1 SECONDS)
	drain_blood()
	var/half_range = round(effectrange / 2)
	var/turf/spot = locate(rand(x - half_range, x + half_range), rand(y - half_range, y + half_range), z)
	if(!spot)
		return
	var/mess_type = pick(/obj/effect/gibspawner/human, /obj/effect/gibspawner/xeno, /obj/effect/gibspawner/generic/animal)
	new mess_type(spot)

/obj/effect/anomaly/veins/detonate()
	for(var/mob/living/carbon/suckee in range(effectrange, src))
		suckee.bleed(200)
		visible_message("<span class='warning'>[suckee] krwawi, a fontanna krwi pędzi w stronę [src]!</span>")
	for(var/i in 1 to 3)
		drain_blood()

/obj/effect/anomaly/veins/planetary
	immortal = TRUE
	immobile = TRUE
	core_anomaly_type = /obj/effect/anomaly/veins

// ---------------------------------------------------------------------------------------------------------------
// Widmowa: z pustki sięgają po ludzi w pobliżu przeklęte dłonie

/obj/effect/anomaly/phantom
	name = "anomalia widmowa"
	desc = "Znajomy zarys. Wzywa towarzystwa. Krzyczy na ciebie."
	icon = 'aquila/icons/planets/anomalies.dmi'
	icon_state = "phantom"
	aSignal = /obj/item/assembly/signaler/anomaly/phantom
	var/effectrange = 3
	var/pulse_delay = 2 SECONDS
	COOLDOWN_DECLARE(pulse_cooldown)

/obj/effect/anomaly/phantom/Initialize(mapload, new_lifespan)
	. = ..()
	pulse_delay = rand(pulse_delay * 0.5, pulse_delay * 1.5)

/obj/effect/anomaly/phantom/anomalyEffect(delta_time)
	..()
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_delay)
	grasp()

/// Przeklęta dłoń dla każdego żywego człowieka w zasięgu, z boku albo z tyłu (jak klątwa nekropolii)
/obj/effect/anomaly/phantom/proc/grasp()
	for(var/mob/living/carbon/handsy in range(effectrange, src))
		if(handsy.stat == DEAD)
			continue
		var/grab_dir = turn(handsy.dir, pick(-90, 90, 180, 180))
		var/turf/spawn_turf = get_ranged_target_turf(handsy, grab_dir, 8)
		if(!spawn_turf)
			continue
		new /obj/effect/temp_visual/dir_setting/curse/grasp_portal(spawn_turf, handsy.dir)
		playsound(spawn_turf, 'sound/effects/curse2.ogg', 80, TRUE, -1)
		var/obj/item/projectile/curse_hand/phantom/hand = new(spawn_turf)
		hand.preparePixelProjectile(handsy, spawn_turf)
		if(QDELETED(hand))
			continue
		hand.fire()

/obj/effect/anomaly/phantom/Bumped(atom/movable/AM)
	grasp()
	new /obj/effect/gibspawner/human(loc)

/obj/effect/anomaly/phantom/detonate()
	grasp()
	new /obj/effect/mob_spawn/human/corpse/damaged/legioninfested(loc)

/obj/effect/anomaly/phantom/planetary
	immortal = TRUE
	immobile = TRUE
	core_anomaly_type = /obj/effect/anomaly/phantom

/obj/item/projectile/curse_hand/phantom
	name = "widmowa dłoń"
	damage = 15
	paralyze = 5

// ---------------------------------------------------------------------------------------------------------------
// Topiąca: kwas na ekwipunek ludzi i leżące przedmioty

/obj/effect/anomaly/melter
	name = "anomalia topiąca"
	desc = "Wiecznie płonący zielony ogień, chętny smagnąć wszystko, co podejdzie za blisko."
	icon = 'aquila/icons/planets/anomalies.dmi'
	icon_state = "melter"
	aSignal = /obj/item/assembly/signaler/anomaly/melter
	var/effectrange = 2
	var/pulse_delay = 10 SECONDS
	COOLDOWN_DECLARE(pulse_cooldown)

/obj/effect/anomaly/melter/Initialize(mapload, new_lifespan)
	. = ..()
	pulse_delay = rand(pulse_delay * 0.5, pulse_delay * 1.5)

/obj/effect/anomaly/melter/anomalyEffect(delta_time)
	..()
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_delay)
	melt(20, 20, 10)

/// Kwas na ekwipunek ludzi w zasięgu i przedmioty na ziemi (bez rdzeni anomalii; Shiptest przerywał całą pętlę
/// na pierwszym rdzeniu)
/obj/effect/anomaly/melter/proc/melt(worn_power, worn_volume, item_volume)
	for(var/mob/living/carbon/meltee in range(effectrange, src))
		for(var/obj/item/worn as anything in meltee.get_equipped_items())
			worn.acid_act(worn_power, worn_volume)
	for(var/obj/item/loose in range(effectrange, src))
		if(istype(loose, /obj/item/assembly/signaler/anomaly))
			continue
		loose.acid_act(worn_power, item_volume)

/obj/effect/anomaly/melter/Bumped(atom/movable/AM)
	if(isitem(AM))
		var/obj/item/acid_target = AM
		acid_target.acid_act(100, 20)

/obj/effect/anomaly/melter/detonate()
	melt(200, 20, 20)

/obj/effect/anomaly/melter/planetary
	immortal = TRUE
	immobile = TRUE
	core_anomaly_type = /obj/effect/anomaly/melter

// ---------------------------------------------------------------------------------------------------------------
// Transfuzyjna: zabiera krew zdrowym, a zebraną oddaje tym, którzy jej potrzebują; przesycona zwraca nadmiar

/obj/effect/anomaly/transfusion
	name = "anomalia transfuzyjna"
	desc = "Pulsujące pole zawieszone w powietrzu, z unoszącymi się w nim szkarłatnymi drobinami."
	icon = 'aquila/icons/planets/anomalies.dmi'
	icon_state = "transfusion"
	density = TRUE
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	aSignal = /obj/item/assembly/signaler/anomaly/transfusion
	var/effectrange = 3
	var/pulse_delay = 5 SECONDS
	COOLDOWN_DECLARE(pulse_cooldown)
	COOLDOWN_DECLARE(pulse_secondary_cooldown)

/obj/effect/anomaly/transfusion/Initialize(mapload, new_lifespan)
	. = ..()
	pulse_delay = rand(pulse_delay * 0.5, pulse_delay * 1.5)

/obj/effect/anomaly/transfusion/anomalyEffect(delta_time)
	..()
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_delay)
	blood_music()

/// Jeden człowiek na puls: bierze krew od zdrowego albo oddaje ją wykrwawionemu (rdzeń trzyma zebraną krew)
/obj/effect/anomaly/transfusion/proc/blood_music()
	var/obj/item/assembly/signaler/anomaly/transfusion/blood_core = aSignal
	if(!istype(blood_core))
		return
	for(var/mob/living/carbon/victim in range(effectrange, src))
		if(blood_core.blood_stored > blood_core.blood_max)
			new /obj/effect/temp_visual/dir_setting/bloodsplatter(loc, pick(GLOB.alldirs))
			visible_message("<span class='boldwarning'>[src] wymiotuje krwią, najwyraźniej syta!</span>")
			blood_core.blood_stored = blood_core.blood_max
			return
		if(!anomaly_can_touch_blood(victim))
			continue
		if(victim.blood_volume > BLOOD_VOLUME_SAFE)
			var/taken = min(rand(10, 30), victim.blood_volume - BLOOD_VOLUME_SAFE)
			victim.blood_volume -= taken
			victim.add_splatter_floor(get_turf(victim), TRUE)
			blood_core.blood_stored += taken
			visible_message("<span class='boldwarning'>Posoka wypływa z [victim] i wpływa do [src]!</span>")
			return
		if(blood_core.blood_stored > blood_core.blood_max / 2)
			var/given = rand(round(blood_core.blood_stored / 10), round(blood_core.blood_stored / 2))
			blood_core.blood_stored -= given
			victim.blood_volume += given
			visible_message("<span class='boldwarning'>Grudki posoki odrywają się od [src] i wpływają do [victim]!</span>")
			return

/obj/effect/anomaly/transfusion/Bumped(atom/movable/AM)
	if(!COOLDOWN_FINISHED(src, pulse_secondary_cooldown))
		return
	COOLDOWN_START(src, pulse_secondary_cooldown, 1 SECONDS)
	if(!iscarbon(AM))
		return
	var/mob/living/carbon/victim = AM
	if(!anomaly_can_touch_blood(victim))
		return
	var/obj/item/assembly/signaler/anomaly/transfusion/blood_core = aSignal
	var/taken = min(rand(50, 200), victim.blood_volume)
	victim.blood_volume -= taken
	victim.add_splatter_floor(get_turf(victim))
	if(istype(blood_core))
		blood_core.blood_stored += taken
	visible_message("<span class='boldwarning'>[victim] dotyka [src], a odsuwając się, traci krew, która odpływa w stronę anomalii!</span>")

/obj/effect/anomaly/transfusion/detonate()
	for(var/mob/living/carbon/victim in range(effectrange, src))
		if(!anomaly_can_touch_blood(victim))
			continue
		victim.blood_volume = max(victim.blood_volume - rand(100, 250), 0)
		victim.add_splatter_floor(get_turf(victim))
	visible_message("<span class='boldwarning'>[src] wrzeszczy, próbując wciągnąć w siebie całą krew dookoła!</span>")

/obj/effect/anomaly/transfusion/planetary
	immortal = TRUE
	immobile = TRUE
	core_anomaly_type = /obj/effect/anomaly/transfusion

/// Fontanna Życia: wieczna, nieruchoma fontanna w kształcie zakrwawionego drzewa (ruiny; sprite drzew lawy z portu lawy)
/obj/effect/anomaly/veins/helltree
	name = "Fontanna Życia"
	desc = "Drzewo pokryte krwią tych, którzy przyszli przed tobą. Da początek przyszłości, nawet jeśli ciebie w niej nie będzie."
	icon = 'aquila/icons/planets/flora/lavatrees.dmi'
	icon_state = "tree_1"
	pixel_x = -16
	layer = ABOVE_MOB_LAYER
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_range = 2
	light_power = 0.85
	resistance_flags = LAVA_PROOF
	immortal = TRUE
	immobile = TRUE
	core_anomaly_type = /obj/effect/anomaly/veins

/obj/effect/anomaly/veins/helltree/Initialize(mapload, new_lifespan)
	. = ..()
	icon_state = "tree_[rand(1, 6)]"
