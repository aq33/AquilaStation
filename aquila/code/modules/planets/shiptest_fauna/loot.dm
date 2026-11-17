// AQUILA: łupy z fauny planety wulkanicznej - port z Shiptest (AGPLv3):
// - dziwny kryształ, odłamek kryształu: code/modules/ruins/rockplanet_ruin_code.dm,
// - kryształowa krawędź (dekoracja barowa): code/modules/food_and_drinks/drinks/drinks/modglass.dm (/obj/item/garnish/crystal),
// - Odczynnik kryształowy: code/modules/reagents/chemistry/reagents/other_reagents.dm (/datum/reagent/crystal_reagent),
// - kryształowe serce: code/modules/mining/equipment/regenerative_core.dm (/obj/item/organ/regenerative_core/legion/crystal),
// - siarkowy pył (plama i odczynnik), czujnik rud: code/modules/mob/living/simple_animal/hostile/mining_mobs/brimdemon.dm.
// Przepis na czujnik rud jest z tgstation (code/datums/components/crafting/equipment.dm, AGPLv3): w Shiptest czujnika nie da
// się zdobyć, u tg robi się go z siarkowego pyłu, kości i ścięgna.
// Ikony (CC BY-SA 3.0): Shiptest icons/obj/lavaland/ash_flora.dmi, icons/obj/mining.dmi, icons/obj/surgery.dmi skopiowane do
// aquila/icons/planets/loot.dmi; czujnik rud na uchu z tgstation icons/mob/clothing/ears.dmi w aquila/icons/planets/loot_worn.dmi.
// Kryształowa krawędź używa ikon dekoracji barowych z Monkestation, które już mamy (aquila/icons/obj/monke/bartending/).
// Różnice względem Shiptest:
// - Odczynnik kryształowy nie działa na rany (nasze rany z aquila/code/modules/wounds/ nie mają reakcji na odczynniki);
// - kryształowe serce: zamiast determinacji (której nie mamy) daje epinefrynę, nasz odpowiednik adrenaliny z systemu bólu;
//   w młynku bez soulusa (nie mamy go); wcieranie w kogoś innego trwa jak przy naszym rdzeniu regeneracyjnym (3 s), a
//   zarażenie nekropolią działa jak przy nim;
// - siarkowy pył w botanice: nasza botanika (Bee) nie ma chwastów ani mocy z tacy, więc pył jest jedną z opcji potrzeb
//   „odstraszanie szkodników” i „leczenie 30%” rośliny (zamiast adjustPests/adjustHealth); mocy (potency) nie podnosi;
// - siarkowy pył parzy o 1 na cykl życia (Shiptest 1 na sekundę, tg 0,5 na sekundę) i ogrzewa ciało do normalnej temperatury.

/// Kryształ z martwego kryształowego goliata albo zapomnianego obserwatora; nożem rozbija się go na dekorację barową
/obj/item/strange_crystal
	name = "dziwny kryształ"
	desc = "Kryształ wydobyty z martwego stworzenia. Jego gwałtowny wzrost i zepsucie zostały wygaszone."
	icon = 'aquila/icons/planets/loot.dmi'
	icon_state = "unnamed_crystal"
	w_class = WEIGHT_CLASS_SMALL
	grind_results = list(/datum/reagent/crystal_reagent = 4)

/obj/item/strange_crystal/attackby(obj/item/item, mob/user, params)
	if(!istype(item, /obj/item/kitchen/knife))
		return ..()
	playsound(src, 'sound/effects/glassbr1.ogg', 50, TRUE, -1)
	to_chat(user, "<span class='notice'>Zaczynasz rozbijać [src] na odłamki...</span>")
	if(!do_after(user, 1 SECONDS, target = src))
		return TRUE
	var/give_to_user = user.is_holding(src)
	var/obj/item/result = new /obj/item/garnish/crystal(drop_location())
	qdel(src)
	if(give_to_user)
		user.put_in_hands(result)
	return TRUE

/// Odłamek ścięty z kryształowej narośli (w Shiptest strugany nożem z kryształowych skał)
/obj/item/crystal_shard
	name = "odłamek kryształu"
	desc = "Odłamek odcięty od dziwnej kryształowej narośli. Obchodź się z nim ostrożnie."
	icon = 'aquila/icons/planets/loot.dmi'
	icon_state = "unnamed_crystal"
	w_class = WEIGHT_CLASS_SMALL
	grind_results = list(/datum/reagent/crystal_reagent = 10)

/// Kryształ rozbity nożem: dekoracja na krawędź szklanki
/obj/item/garnish/crystal
	name = "kryształowa krawędź"
	desc = "Na pewno nic nie może pójść źle."
	icon_state = "crystal"
	garnish_state = "crystal"

/// Leczy po trochu wszystko, przedawkowany rozrywa serce; polany na martwe zwęglone ciało cofa jego zwęglenie
/datum/reagent/crystal_reagent
	name = "Odczynnik kryształowy"
	description = "Dziwna krystaliczna substancja o imponujących właściwościach leczniczych."
	reagent_state = LIQUID
	color = "#1B9681"
	chem_flags = CHEMICAL_NOT_SYNTH
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 20
	taste_description = "ostre kamienie"
	/// Ile każdego rodzaju obrażeń leczy na cykl
	var/healing = 2

/datum/reagent/crystal_reagent/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	. = ..()
	if(!iscarbon(M))
		return
	var/mob/living/carbon/patient = M
	if(reac_volume >= 5 && HAS_TRAIT_FROM(patient, TRAIT_HUSK, "burn") && patient.stat == DEAD)
		patient.adjustFireLoss(-500)
		patient.cure_husk("burn")
		patient.visible_message("<span class='nicegreen'>Ciało [patient] drży, gdy wnika w nie kryształ. Spalona skóra odzyskuje zwykły kolor, a pod nią rosną kryształy!</span>")
		patient.adjustCloneLoss(10)
		patient.do_jitter_animation(200)

/datum/reagent/crystal_reagent/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(-healing * REM, 0)
	M.adjustOxyLoss(-healing * REM, 0)
	M.adjustBruteLoss(-healing * REM, 0)
	M.adjustFireLoss(-healing * REM, 0)
	..()
	. = 1

/datum/reagent/crystal_reagent/overdose_process(mob/living/M)
	to_chat(M, "<span class='danger'>Czujesz, jak twoje serce pęka na dwoje!</span>")
	M.adjustStaminaLoss(10)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, 100)
	if(iscarbon(M))
		var/mob/living/carbon/carbon_mob = M
		carbon_mob.set_heartattack(TRUE)
	..()

/// Serce zniekształconego legionu: leczy jak rdzeń legionu i dodaje epinefrynę
/obj/item/organ/regenerative_core/legion/crystal
	name = "kryształowe serce"
	desc = "Dziwny kamień w kształcie serca. Wtarte w ciało naprawia je kryształami, ale może mieć skutki uboczne. Wygląda na to, że poza nosicielem długo nie przetrwa."
	icon = 'aquila/icons/planets/loot.dmi'
	icon_state = "crystal_heart"
	grind_results = list(/datum/reagent/blood = 10)

/obj/item/organ/regenerative_core/legion/crystal/update_icon()
	if(inert)
		icon_state = "crystal_heart_inert"
	else if(preserved)
		icon_state = "crystal_heart_preserved"
	else
		icon_state = "crystal_heart"
	cut_overlays()
	for(var/datum/action/action as anything in actions)
		action.UpdateButtonIcon()

/obj/item/organ/regenerative_core/legion/crystal/go_inert()
	..()
	name = "zepsute kryształowe serce"

/// Shiptest: zakonserwowane daje popiół, świeże krew, oba odrobinę determinacji (u nas epinefryny); soulusa nie mamy
/obj/item/organ/regenerative_core/legion/crystal/on_grind()
	if(inert || preserved)
		grind_results = list(/datum/reagent/ash = 30, /datum/reagent/medicine/epinephrine = 1)
	else
		grind_results = list(/datum/reagent/blood = rand(5, 15), /datum/reagent/medicine/epinephrine = 1)
	return ..()

/obj/item/organ/regenerative_core/legion/crystal/applyto(atom/target, mob/user)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	if(inert)
		to_chat(user, "<span class='notice'>[src] uległo rozkładowi i nie nadaje się już do leczenia.</span>")
		return
	if(H.stat == DEAD)
		to_chat(user, "<span class='notice'>[src] jest bezużyteczne na martwych.</span>")
		return
	if(H != user)
		to_chat(user, "<span class='notice'>Zaczynasz wcierać [src] w [H]...</span>")
		to_chat(H, "<span class='userdanger'>[user] zaczyna rozsmarowywać na tobie [src]...</span>")
		if(!do_mob(user, H, 30))
			return
		H.visible_message("<span class='notice'>[user] rozsmarowuje [src] na [H]... Złośliwe kryształy i rakowate wici porastają ciało, wzmacniając je!</span>")
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "other"))
	else
		to_chat(user, "<span class='notice'>Rozsmarowujesz na sobie [src]. Złośliwe kryształy i rakowate wici porastają cię, wzmacniając i lecząc tam, gdzie dotkną.</span>")
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "self"))
	if(HAS_TRAIT(H, TRAIT_NECROPOLIS_INFECTED))
		H.ForceContractDisease(new /datum/disease/transformation/legion())
		to_chat(H, "<span class='userdanger'>Czujesz, jak nekropolia zacieśnia uścisk na twoim sercu i duszy... Już niedługo nie będziesz w stanie się opierać...</span>")
	H.apply_status_effect(STATUS_EFFECT_REGENERATIVE_CORE)
	H.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 4)
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "core", /datum/mood_event/healsbadman)
	qdel(src)

/// Plama po siarkodemonie: 15 j. siarkowego pyłu do zgarnięcia zlewką
/obj/effect/decal/cleanable/brimdust
	name = "siarkowy pył"
	desc = "Pył z siarkodemona. Ceniony w botanice i do ogrzewania."
	icon = 'aquila/icons/planets/loot.dmi'
	icon_state = "brimdust"
	mergeable_decal = FALSE
	decal_reagent = /datum/reagent/brimdust
	reagent_amount = 15

/// Grzeje ciało kosztem lekkich oparzeń; w botanice odstrasza szkodniki i leczy roślinę
/datum/reagent/brimdust
	name = "Siarkowy pył"
	description = "Pył siarkodemona. Stale chroni ciało przed wychłodzeniem kosztem pełzających oparzeń. Pełen związków azotu, idealnych jako nawóz dla roślin."
	reagent_state = SOLID
	color = "#522546"
	chem_flags = NONE
	taste_description = "siarkowy płomień"

/datum/reagent/brimdust/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(1, 0)
	M.adjust_bodytemperature(5 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()
	. = 1

/// Siarkowy pył jako jedna z opcji odstraszania szkodników (Shiptest: adjustPests(-1) i adjustWeeds(-1))
/datum/plant_need/reagent/buff/pests/New(datum/plant_feature/_parent)
	reagent_needs[/datum/reagent/brimdust] = 1
	return ..()

/// Siarkowy pył jako jedna z opcji leczenia rośliny (Shiptest: adjustHealth o ilość pyłu)
/datum/plant_need/reagent/buff/heal/tier_2/New(datum/plant_feature/_parent)
	reagent_needs[/datum/reagent/brimdust] = 1
	return ..()

/// Noszony na uchu: co 4 s pokazuje rudy w promieniu 5 pól
/obj/item/ore_sensor
	name = "czujnik rud"
	desc = "Noszone na uchu narzędzie, które na demonicznych częstotliwościach wykrywa rudy w okolicznych skałach."
	icon = 'aquila/icons/planets/loot.dmi'
	icon_state = "oresensor"
	worn_icon = 'aquila/icons/planets/loot_worn.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_EARS
	/// Zasięg skanu w polach
	var/range = 5
	/// Między zwykłym a zaawansowanym skanerem górniczym
	var/cooldown = 4 SECONDS
	COOLDOWN_DECLARE(ore_sensing_cooldown)

/obj/item/ore_sensor/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/ore_sensor/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_EARS)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/ore_sensor/dropped(mob/user, silent)
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/ore_sensor/process(delta_time)
	if(!COOLDOWN_FINISHED(src, ore_sensing_cooldown))
		return
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	COOLDOWN_START(src, ore_sensing_cooldown, cooldown)
	// mineral_scan_pulse() śpi między pierścieniami skanu
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(mineral_scan_pulse), our_turf, range)

/// Przepis tg: siarkowy pył zgarnięty do zlewki, kość i ścięgno
/datum/crafting_recipe/ore_sensor
	name = "czujnik rud"
	result = /obj/item/ore_sensor
	time = 3 SECONDS
	reqs = list(
		/datum/reagent/brimdust = 15,
		/obj/item/stack/sheet/bone = 1,
		/obj/item/stack/sheet/sinew = 1,
	)
	category = CAT_PRIMAL
