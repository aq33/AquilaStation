// Diona z BeeStation-Hornet (code/modules/mob/living/carbon/human/species_types/diona.dm).
// Gestalt nimf: fotosynteza, leczenie promieniowaniem, rozpad na nimfy przy śmierci i w stanie krytycznym,
// odszczepianie nimfy po najedzeniu się. Nimfa: aquila/code/modules/mob/living/simple_animal/hostile/retaliate/nymph.dm.
/datum/species/diona
	name = "\improper Diona"
	id = SPECIES_DIONA
	sexes = FALSE
	default_color = "59CE00"
	species_traits = list(MUTCOLORS, NOEYESPRITES, AGENDER, NO_UNDERWEAR, NOHUSK, NO_DNA_COPY) // U Bee głowa bez rysowanych oczu, oczy to wyrostki
	inherent_traits = list(TRAIT_BEEFRIEND, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD, TRAIT_RADHEALER, TRAIT_NOBREATH)
	inherent_biotypes = list(MOB_HUMANOID, MOB_ORGANIC, MOB_BUG)
	inherent_factions = list("plants", "vines", FACTION_DIONA)
	mutant_bodyparts = list(FEATURE_DIONA_LEAVES, FEATURE_DIONA_THORNS, FEATURE_DIONA_FLOWERS, FEATURE_DIONA_MOSS, FEATURE_DIONA_MUSHROOM, FEATURE_DIONA_ANTENNAE, FEATURE_DIONA_EYES, FEATURE_DIONA_PBODY)
	default_features = list(
		"mcolor" = "59CE00",
		FEATURE_DIONA_LEAVES = "Brak",
		FEATURE_DIONA_THORNS = "Brak",
		FEATURE_DIONA_FLOWERS = "Brak",
		FEATURE_DIONA_MOSS = "Brak",
		FEATURE_DIONA_MUSHROOM = "Brak",
		FEATURE_DIONA_ANTENNAE = "Brak",
		FEATURE_DIONA_EYES = "Brak",
		FEATURE_DIONA_PBODY = "Brak",
		"body_size" = "Normal",
	)
	heatmod = 1.5
	// U Bee modyfikatory na każdej kończynie: oparzenia 1.25, obrażenia fizyczne 0.8, wytrzymałość 0.7, nogi spowalniają po 0.6
	burnmod = 1.25
	brutemod = 0.8
	staminamod = 0.7
	speedmod = 1.2
	meat = /obj/item/food/meat/slab/human/mutant/plant
	species_gibs = null // jak u Bee: diona nie zostawia flaków
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP
	species_language_holder = /datum/language_holder/diona
	deathsound = 'aquila/sound/emotes/diona/death.ogg'
	use_skintones = FALSE
	attack_verb = "slash"
	attack_sound = 'aquila/sound/emotes/diona/hit.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	mutanteyes = /obj/item/organ/eyes/diona
	mutanttongue = /obj/item/organ/tongue/diona

	species_chest = /obj/item/bodypart/chest/diona
	species_head = /obj/item/bodypart/head/diona
	species_l_arm = /obj/item/bodypart/l_arm/diona
	species_r_arm = /obj/item/bodypart/r_arm/diona
	species_l_leg = /obj/item/bodypart/l_leg/diona
	species_r_leg = /obj/item/bodypart/r_leg/diona

	/// Rozpad na nimfy na żądanie
	var/datum/action/diona_split/split_ability
	/// Odszczepienie nimfy, gdy diona jest najedzona
	var/datum/action/cooldown/diona_partition/partition_ability
	/// Ile ticków Life() z rzędu diona stoi w świetle
	var/time_spent_in_light = 0
	/// Czy diona dostała już wiadomość, że może odszczepić nimfę
	var/informed_nymph = FALSE
	/// Rozpad już trwa
	var/splitting = FALSE

/mob/living/carbon/human/species/diona
	race = /datum/species/diona

// Plik w pojedynczych cudzysłowach trafia do .rsc, więc działa też po tools/deploy.sh (ten nie kopiuje aquila/strings)
GLOBAL_LIST_INIT(diona_names, splittext(trim(file2text('aquila/strings/names/diona.txt')), "\n"))

/// Gestalt przyjmuje imię od wspólnego wspomnienia nimf
/datum/species/diona/random_name(gender, unique, lastname, attempts)
	for(var/i in 1 to (unique ? (attempts || 10) : 1))
		. = pick(GLOB.diona_names)
		if(!unique || !findname(.))
			return

/datum/species/diona/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	if(ishuman(C))
		bee_sanitize_features(C)
	. = ..()
	split_ability = new
	split_ability.Grant(C)
	partition_ability = new
	partition_ability.Grant(C)

/datum/species/diona/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	QDEL_NULL(split_ability)
	QDEL_NULL(partition_ability)
	C.remove_status_effect(/datum/status_effect/diona_planthealing)

/datum/species/diona/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	. = ..()
	bee_add_feature_overlays(H, mutant_bodyparts, forced_colour)

/datum/species/diona/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.fire_stacks < 1)
		H.adjust_fire_stacks(1) // BARDZO łatwopalna
	if(H.nutrition < NUTRITION_LEVEL_STARVING)
		H.take_overall_damage(brute = 1, required_status = BODYTYPE_ORGANIC)
	if(H.stat != CONSCIOUS)
		H.remove_status_effect(/datum/status_effect/diona_planthealing)
	if(H.stat != DEAD && H.health <= H.crit_threshold) // Umieramy! W rozsypkę!
		diona_split(H)
		return
	if(H.nutrition > NUTRITION_LEVEL_WELL_FED && !informed_nymph)
		informed_nymph = TRUE
		to_chat(H, "<span class='warning'>Jesteś dość najedzona, by odszczepić nimfę od swojego gestaltu!</span>")
	partition_ability?.UpdateButtonIcon()
	if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
		H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)
	if(!isturf(H.loc)) // Poza kafelkiem nie ma światła
		H.remove_status_effect(/datum/status_effect/diona_planthealing)
		time_spent_in_light = 0
		return
	var/turf/T = H.loc
	var/light_amount = min(1, T.get_lumcount()) - 0.5
	H.adjust_nutrition(light_amount * 7)
	if(light_amount > 0.2)
		time_spent_in_light++
		if(time_spent_in_light > 5)
			if(H.stat != CONSCIOUS)
				H.remove_status_effect(/datum/status_effect/diona_planthealing)
				return
			H.apply_status_effect(/datum/status_effect/diona_planthealing)
	else
		time_spent_in_light = 0
		H.remove_status_effect(/datum/status_effect/diona_planthealing)

/// Diona żywi się promieniowaniem i leczy się nim. Jak u Bee bez bazowej procki, która powala i wywołuje wymioty.
/datum/species/diona/handle_radiation(mob/living/carbon/human/H, intensity, delta_time)
	H.adjust_nutrition(intensity * 0.1 * delta_time)
	if(intensity > 50)
		H.heal_overall_damage(brute = 1 * delta_time, burn = 1 * delta_time, required_status = BODYTYPE_ORGANIC)
		H.adjustToxLoss(-2 * delta_time)
		H.adjustOxyLoss(-1 * delta_time)

/datum/species/diona/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	. = ..()
	if(.)
		return
	if(chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(1.5 * REM)
	else if(chem.type == /datum/reagent/toxin/mutagen)
		H.adjustToxLoss(-1.5 * REM)
	else if(chem.type == /datum/reagent/plantnutriment)
		H.adjustBruteLoss(-0.5 * REM)
		H.adjustFireLoss(-0.5 * REM)

/// Promienie z floralnego działka karmią dionę
/datum/species/diona/on_hit(obj/item/projectile/P, mob/living/carbon/human/H)
	if(istype(P, /obj/item/projectile/energy/floramut) || istype(P, /obj/item/projectile/energy/florayield))
		H.set_nutrition(min(H.nutrition + 30, NUTRITION_LEVEL_FULL))
		return
	return ..()

/datum/species/diona/spec_death(gibbed, mob/living/carbon/human/H)
	. = ..()
	if(gibbed || QDELETED(H))
		return
	// Po zakończeniu death(), które dalej korzysta z ciała
	addtimer(CALLBACK(src, PROC_REF(diona_split), H), 1)

/// Przytulając płonącego, diona sama się zapala
/datum/species/diona/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	. = ..()
	if(. && target != user && target.on_fire)
		target.visible_message("<span class='warning'>[user] zapala się, przytulając [target]!</span>", "<span class='boldnotice'>[user] zapala się, przytulając cię!</span>", "<span class='italics'>Słyszysz trzask ognia.</span>")
		user.fire_stacks = max(user.fire_stacks, target.fire_stacks)
		if(user.fire_stacks > 0)
			user.IgniteMob()

/// Rozpad gestaltu: z każdej kończyny diony wychodzi nimfa, gracz trafia do nimfy z głowy (albo innej żywej)
/datum/species/diona/proc/diona_split(mob/living/carbon/human/H)
	if(splitting || QDELETED(H) || H.dna?.species != src)
		return
	splitting = TRUE
	var/turf/T = get_turf(H)
	var/list/mob/living/simple_animal/hostile/retaliate/nymph/alive_nymphs = list()
	var/mob/living/simple_animal/hostile/retaliate/nymph/player_nymph = new(T)
	for(var/obj/item/bodypart/limb as anything in H.bodyparts.Copy())
		if(limb.limb_id != SPECIES_DIONA) // Proteza albo cudza kończyna
			limb.drop_limb(TRUE)
			continue
		if(limb.body_zone == BODY_ZONE_HEAD)
			player_nymph.adjustBruteLoss(limb.brute_dam, FALSE)
			player_nymph.adjustFireLoss(limb.burn_dam, FALSE)
			player_nymph.updatehealth()
			continue
		var/mob/living/simple_animal/hostile/retaliate/nymph/limb_nymph = new(T)
		limb_nymph.adjustBruteLoss(limb.brute_dam, FALSE)
		limb_nymph.adjustFireLoss(limb.burn_dam, FALSE)
		limb_nymph.updatehealth()
		if(limb_nymph.stat != DEAD)
			alive_nymphs += limb_nymph
	if(length(alive_nymphs))
		var/mob/living/simple_animal/hostile/retaliate/nymph/unlucky = pick(alive_nymphs) // Hazard!
		unlucky.adjustBruteLoss(50)
		alive_nymphs -= unlucky
	if(player_nymph.stat == DEAD && length(alive_nymphs)) // Nimfa z głowy nie żyje, świadomość idzie do żywej
		player_nymph = pick(alive_nymphs)
	for(var/obj/item/I in H.get_equipped_items(TRUE) + H.held_items)
		if(H.dropItemToGround(I, TRUE))
			I.pixel_x = rand(-10, 10)
			I.pixel_y = rand(-10, 10)
	player_nymph.old_name = H.real_name
	player_nymph.features = H.dna.features.Copy()
	if(H.mind)
		H.mind.transfer_to(player_nymph)
		player_nymph.mind.grab_ghost()
	else if(H.key)
		player_nymph.key = H.key
	H.visible_message("<span class='warning'>[H] rozpada się na chmarę nimf!</span>")
	H.gib(TRUE, TRUE, TRUE)
	return player_nymph

/datum/species/diona/get_species_description()
	return "Diony to odpowiednik człapiącego kopca owadopodobnych rozumnych roślin, które włożyły prochowiec \
		i udają człowieka. Często można je spotkać w komorze supermaterii, gdzie wygrzewają się w przerwie na lunch."

/datum/species/diona/get_species_lore()
	return list(
		"Diony to podróżujący w kosmosie gatunek niezwykle ciekawskich, rozumnych stworzeń na pół roślin, na pół owadów. \
			Tworzy je zbiorowisko niezależnych istot zwanych nimfami, które łączą się w kolektyw zwany gestaltem. \
			Zwykle mgliście przypomina on humanoida, choć starsze kolektywy potrafią urosnąć w budowle, \
			a nawet w dryfujące w kosmosie asteroidy.",
		"Kultura dion jest w większości koczownicza: gestalty rodzicielskie odszczepiają pąk, który wyrusza w świat, \
			by na własną rękę go poznawać i zdobywać wiedzę. Rzadko kilka gestaltów spotyka się w umówionym miejscu, \
			by podzielić się wiedzą albo stworzyć większą budowlę.",
		"Gestalt to zbiór nimf o różnych doświadczeniach, więc z imionami bywa kłopot. Gestalty wybierają jedno \
			wspólne wszystkim nimfom wspomnienie, najczęściej z młodości, i rozwijają je z czasem, gdy wracają do \
			swoich wspomnień. Zdarza się też, że gestalt całkiem zmienia imię, gdy świeższe wspomnienie lepiej go oddaje.",
	)

/datum/species/diona/create_pref_unique_perks()
	return list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "sun-plant-wilt",
			SPECIES_PERK_NAME = "Fotosynteza",
			SPECIES_PERK_DESC = "Światło i promieniowanie bardzo ci smakują, ale bez nich długo nie pożyjesz!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bugs",
			SPECIES_PERK_NAME = "Robaczy wybuch",
			SPECIES_PERK_DESC = "Gdy jesteś bliska śmierci, rozpadasz się na kupkę nimf i uciekasz, ale w tej postaci jesteś bardzo bezbronna!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "leaf",
			SPECIES_PERK_NAME = "Roślinność",
			SPECIES_PERK_DESC = "Jesteś rośliną! Pszczoły cię lubią, ty UWIELBIASZ nawóz i nienawidzisz środków chwastobójczych.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Łatwopalność",
			SPECIES_PERK_DESC = "Zapala cię najmniejszy płomień, uważaj!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "weight-hanging",
			SPECIES_PERK_NAME = "Ociężałość",
			SPECIES_PERK_DESC = "Jako roślina nie jesteś zbyt zwinna, chodzenie zajmuje ci więcej czasu.",
		),
	)

// Fotosynteza (u Bee /datum/status_effect/planthealing)

/datum/status_effect/diona_planthealing
	id = "Photosynthesis"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	tick_interval = 2.6 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/diona_planthealing
	examine_text = "<span class='notice'>Liście SUBJECTPRONOUN rozkwitają w świetle!</span>"

/datum/status_effect/diona_planthealing/tick()
	owner.heal_overall_damage(1, 1, 0, BODYTYPE_ORGANIC)

/atom/movable/screen/alert/status_effect/diona_planthealing
	name = "Fotosynteza"
	desc = "Światło leczy twoje rany."
	icon = 'aquila/icons/mob/species/diona/alert.dmi'
	icon_state = "blooming"

// Akcje

/datum/action/diona_split
	name = "Rozpad"
	desc = "Rozpadnij się na oddzielne nimfy."
	icon_icon = 'aquila/icons/mob/species/diona/actions.dmi'
	button_icon_state = "split"
	/// Odliczanie do rozpadu już trwa
	var/activated = FALSE

/datum/action/diona_split/IsAvailable()
	return ..() && isdiona(owner) && owner.stat != DEAD

/datum/action/diona_split/Trigger()
	if(!..() || activated)
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(tgui_alert(H, "Czy na pewno chcemy się uwstecznić i rozpaść na oddzielne nimfy?", "Rozpad", list("Tak", "Nie")) != "Tak")
		return FALSE
	if(QDELETED(src) || owner != H || !do_after(H, 8 SECONDS, target = H))
		return FALSE
	if(H.restrained()) // Gdyby ktoś skuł nas w ostatniej chwili
		return FALSE
	activated = TRUE
	H.Stun(6 SECONDS)
	var/datum/species/diona/diona = H.dna.species
	addtimer(CALLBACK(diona, TYPE_PROC_REF(/datum/species/diona, diona_split), H), 5 SECONDS)
	return TRUE

/datum/action/cooldown/diona_partition
	name = "Odszczepienie"
	desc = "Pozwól nimfie odszczepić się od naszego gestaltu."
	icon_icon = 'aquila/icons/mob/species/diona/actions.dmi'
	button_icon_state = "grow"
	cooldown_time = 5 MINUTES

/datum/action/cooldown/diona_partition/IsAvailable()
	if(!..() || !ishuman(owner) || owner.stat)
		return FALSE
	return owner.nutrition >= NUTRITION_LEVEL_WELL_FED

/datum/action/cooldown/diona_partition/Trigger()
	if(!owner || !..())
		return FALSE
	var/mob/living/carbon/human/H = owner
	H.set_nutrition(NUTRITION_LEVEL_STARVING)
	playsound(H, 'aquila/sound/emotes/diona/venus_trap_death.ogg', 25, TRUE)
	new /mob/living/simple_animal/hostile/retaliate/nymph(H.loc)
	StartCooldown()
	return TRUE

// Części ciała (szare, barwione kolorem mutanta jak u Bee)

/obj/item/bodypart/head/diona
	is_dimorphic = FALSE
	icon = 'aquila/icons/mob/species/diona/bodyparts.dmi'
	static_icon = 'aquila/icons/mob/species/diona/bodyparts.dmi'
	limb_id = SPECIES_DIONA
	dismemberable = FALSE // U Bee BODYPART_UNREMOVABLE

/obj/item/bodypart/chest/diona
	is_dimorphic = FALSE
	icon = 'aquila/icons/mob/species/diona/bodyparts.dmi'
	static_icon = 'aquila/icons/mob/species/diona/bodyparts.dmi'
	limb_id = SPECIES_DIONA

/obj/item/bodypart/l_arm/diona
	icon = 'aquila/icons/mob/species/diona/bodyparts.dmi'
	static_icon = 'aquila/icons/mob/species/diona/bodyparts.dmi'
	limb_id = SPECIES_DIONA

/obj/item/bodypart/r_arm/diona
	icon = 'aquila/icons/mob/species/diona/bodyparts.dmi'
	static_icon = 'aquila/icons/mob/species/diona/bodyparts.dmi'
	limb_id = SPECIES_DIONA

/obj/item/bodypart/l_leg/diona
	icon = 'aquila/icons/mob/species/diona/bodyparts.dmi'
	static_icon = 'aquila/icons/mob/species/diona/bodyparts.dmi'
	limb_id = SPECIES_DIONA

/obj/item/bodypart/r_leg/diona
	icon = 'aquila/icons/mob/species/diona/bodyparts.dmi'
	static_icon = 'aquila/icons/mob/species/diona/bodyparts.dmi'
	limb_id = SPECIES_DIONA

/// U Bee kończyna diony to nimfa: odcięta odchodzi jako nimfa, a kończyna znika
/proc/diona_limb_to_nymph(obj/item/bodypart/limb, mob/living/carbon/old_owner, special)
	if(special || !old_owner || old_owner.stat == DEAD || !isdiona(old_owner) || QDELETED(limb))
		return
	new /mob/living/simple_animal/hostile/retaliate/nymph(get_turf(old_owner))
	QDEL_IN(limb, 0)

/obj/item/bodypart/l_arm/diona/drop_limb(special)
	var/mob/living/carbon/old_owner = owner
	. = ..()
	diona_limb_to_nymph(src, old_owner, special)

/obj/item/bodypart/r_arm/diona/drop_limb(special)
	var/mob/living/carbon/old_owner = owner
	. = ..()
	diona_limb_to_nymph(src, old_owner, special)

/obj/item/bodypart/l_leg/diona/drop_limb(special)
	var/mob/living/carbon/old_owner = owner
	. = ..()
	diona_limb_to_nymph(src, old_owner, special)

/obj/item/bodypart/r_leg/diona/drop_limb(special)
	var/mob/living/carbon/old_owner = owner
	. = ..()
	diona_limb_to_nymph(src, old_owner, special)

// Organy

/obj/item/organ/eyes/diona
	name = "węzeł receptorowy"
	desc = "Połączenie materii roślinnej i neuronów, które daje obraz."
	icon = 'aquila/icons/mob/species/diona/organs.dmi'
	icon_state = "diona_eyeballs"
	flash_protect = -1 // U Bee FLASH_PROTECTION_SENSITIVE

/obj/item/organ/tongue/diona
	name = "język diony"
	desc = "Dziwny język, chyba z materii roślinnej."
	icon = 'aquila/icons/mob/species/diona/organs.dmi'
	icon_state = "diona_tongue"
	say_mod = "szeleści"
	ask_mod = "drży"
	yell_mod = "piszczy"
	exclaim_mod = "faluje"
	liked_food = MEAT | RAW
	disliked_food = DAIRY | FRUIT | GRAIN | CLOTH | VEGETABLES

/datum/language_holder/diona
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/sylvan = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/sylvan = list(LANGUAGE_ATOM))

// Dźwięki i emotki (u Bee get_scream_sound, get_laugh_sound, get_sneeze_sound i emotki diony)

/datum/emote/living/carbon/human/scream/get_sound(mob/living/user)
	if(isdiona(user) && !user.mind?.miming)
		return 'aquila/sound/emotes/diona/scream.ogg'
	return ..()

/datum/emote/living/laugh/get_sound(mob/living/user)
	if(isdiona(user) && !user.mind?.miming)
		return 'aquila/sound/emotes/diona/laugh.ogg'
	return ..()

/datum/emote/living/sneeze/get_sound(mob/living/user)
	if(isdiona(user) && !user.mind?.miming)
		return 'aquila/sound/emotes/diona/sneeze.ogg'
	return ..()

/datum/emote/living/carbon/human/diona
	mob_type_allowed_typecache = list(/mob/living/carbon/human, /mob/living/simple_animal/hostile/retaliate/nymph)

/datum/emote/living/carbon/human/diona/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE
	if(ishuman(user))
		return isdiona(user)
	return isnymph(user)

/datum/emote/living/carbon/human/diona/chitter
	key = "chitter"
	key_third_person = "chitters"
	name = "zaterkocz"
	message = "terkocze"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'aquila/sound/emotes/diona/chitter.ogg'

/datum/emote/living/carbon/human/diona/cricket
	key = "cricket"
	key_third_person = "chirps"
	name = "zacykaj"
	message = "cyka jak świerszcz"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'aquila/sound/emotes/diona/cricket.ogg'
	sound_volume = 30
