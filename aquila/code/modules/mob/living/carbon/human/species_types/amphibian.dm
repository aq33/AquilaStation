// Żaba (Amphibian), port z Goonstation (goonstation/goonstation: code/datums/mutantraces.dm /datum/mutantrace/frog i
// /datum/mutantrace/frog/amphibian, cecha „Amphibian” z traits.dm, akcent żaby z procs/accents.dm, lepki język z
// bioEffects/powers.dm). Licencja CC BY-NC-SA 3.0, autorzy: zespół Goonstation. Grafika i dźwięki też z Goona.
// W Goonie żaba to mutantrace z cechy postaci. U nas zwykła rasa z oknem postaci i odmianą skóry do wyboru.
// Pominięte: filtry zniekształcające ubrania (ciało jest przełożone na nasz szablon, więc ubrania pasują bez nich),
// pragnienie tylko dla żab (u nas pragnienie mają wszyscy), osobne narządy płazów (w Goonie to tylko inne ikony).

/// Goon movement_modifier/amphibian: additive_slowdown 1.2
#define AMPHIBIAN_SLOWDOWN 1.2
/// Goon: blood_color
#define AMPHIBIAN_BLOOD_COLOR "#50b558"
/// Goon dermal_absorbtion(5): ile jednostek cieczy z podłogi wchłania skóra
#define AMPHIBIAN_ABSORB_AMOUNT 5
/// Zasięg języka (Goon datum/projectile/special/tongue max_range)
#define AMPHIBIAN_TONGUE_RANGE 4
#define AMPHIBIAN_TONGUE_ICON 'aquila/icons/mob/species/amphibian/tongue.dmi'
/// Spowolnienie po strzale językiem (Goon: status „slowed” na 2 s)
#define MOVESPEED_ID_AMPHIBIAN_TONGUE "amphibian_tongue"

/// Odmiany skóry żaby (Goon special_styles): odmiana -> polska nazwa
GLOBAL_LIST_INIT(amphibian_skins, list(
	"frog" = "Zielona",
	"golden" = "Złota",
	"lichen" = "Porostowa",
	"russet" = "Rdzawa",
	"gills" = "Ze skrzelami",
))

/// Robactwo, które żaba połyka językiem w całości (Goon: small_animal z edible_insect)
GLOBAL_LIST_INIT(amphibian_edible_insects, typecacheof(list(
	/mob/living/basic/cockroach,
	/mob/living/basic/butterfly,
	/mob/living/basic/mothroach,
	/mob/living/simple_animal/hostile/poison/bees,
)))

/datum/species/amphibian
	name = "\improper Żaba"
	id = SPECIES_AMPHIBIAN
	species_traits = list(EYECOLOR)
	inherent_traits = list(TRAIT_AQUATIC)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	default_features = list(FEATURE_AMPHIBIAN_SKIN = "frog", "body_size" = "Normal")
	use_skintones = FALSE
	// Goon: brutevuln 0.7, firevuln 1.3, toxvuln 2
	brutemod = 0.7
	burnmod = 1.3
	toxmod = 2
	speedmod = AMPHIBIAN_SLOWDOWN
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	mutanttongue = /obj/item/organ/tongue/amphibian
	swimming_component = /datum/component/swimming/amphibian
	goon_voice = "amphibian"

	species_chest = /obj/item/bodypart/chest/amphibian
	species_head = /obj/item/bodypart/head/amphibian
	species_l_arm = /obj/item/bodypart/l_arm/amphibian
	species_r_arm = /obj/item/bodypart/r_arm/amphibian
	species_l_leg = /obj/item/bodypart/l_leg/amphibian
	species_r_leg = /obj/item/bodypart/r_leg/amphibian

	/// Grupa cieczy, z której ostatnio piła skóra (komunikat tylko przy nowej kałuży)
	var/datum/weakref/last_liquid_group

/mob/living/carbon/human/species/amphibian
	race = /datum/species/amphibian

/datum/species/amphibian/on_species_gain(mob/living/carbon/human/C, datum/species/old_species, pref_load)
	. = ..()
	if(!(C.dna.features[FEATURE_AMPHIBIAN_SKIN] in GLOB.amphibian_skins))
		C.dna.features[FEATURE_AMPHIBIAN_SKIN] = default_features[FEATURE_AMPHIBIAN_SKIN]
	var/datum/action/cooldown/mob_cooldown/sticky_tongue/tongue = new(C)
	tongue.Grant(C)

/datum/species/amphibian/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/sticky_tongue/tongue = locate() in C.actions
	qdel(tongue)
	C.remove_movespeed_modifier(MOVESPEED_ID_AMPHIBIAN_TONGUE)

/datum/species/amphibian/handle_body(mob/living/carbon/human/H)
	. = ..()
	monke_replace_eye_icon(H, AMPHIBIAN_BODYPARTS_ICON)

/datum/species/amphibian/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD) // martwa skóra nie wchłania
		return
	dermal_absorption(H)

/// Goon dermal_absorbtion(): skóra wchłania ciecz, w której stoi żaba, chyba że chroni ją szczelny strój
/datum/species/amphibian/proc/dermal_absorption(mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	var/datum/liquid_group/group = T?.liquids?.liquid_group
	if(!group || group.frozen || !group.reagents?.total_volume)
		last_liquid_group = null
		return
	if(!isturf(H.loc) || H.is_liquid_protected())
		return
	if(!prob(30))
		return
	var/amount = min(AMPHIBIAN_ABSORB_AMOUNT, group.reagents.total_volume, H.reagents.maximum_volume - H.reagents.total_volume)
	if(amount <= 0)
		return
	group.transfer_to_atom(T.liquids, amount, H, TOUCH)
	playsound(H, 'sound/items/drink.ogg', rand(10, 20), TRUE)
	if(last_liquid_group?.resolve() != group)
		last_liquid_group = WEAKREF(group)
		H.visible_message("<span class='notice'>Skóra [H] zaczyna wchłaniać otaczającą ciecz.</span>", "<span class='notice'>Twoja skóra zaczyna wchłaniać otaczającą ciecz.</span>")

/// Goon blood_color: zielona krew
/mob/living/carbon/human/get_blood_color()
	if(isamphibian(src))
		return AMPHIBIAN_BLOOD_COLOR
	return ..()

// Woda (Goon: aquatic, oddycha pod wodą i nie zwalnia w cieczach)

/datum/component/swimming/amphibian
	slowdown = 0

/datum/component/swimming/amphibian/enter_pool()
	to_chat(parent, "<span class='notice'>Woda! Wreszcie czujesz się jak w domu.</span>")

/datum/component/swimming/amphibian/is_drowning(mob/living/victim)
	return FALSE

/datum/status_effect/swimming/is_drowning()
	if(HAS_TRAIT(owner, TRAIT_AQUATIC))
		return FALSE
	return ..()

/datum/status_effect/water_affected/calculate_water_slow()
	. = ..()
	if(. && HAS_TRAIT(owner, TRAIT_AQUATIC))
		owner.remove_movespeed_modifier(MOVESPEED_ID_LIQUIDS)

// Mowa

/obj/item/organ/tongue/amphibian
	name = "język żaby"
	desc = "Długi, lepki język. Świetnie łapie muchy."
	say_mod = "rechocze"
	modifies_speech = TRUE

/// Goon: podwojone „r” (repeated_letter/amphibian) i akcent żaby (frogify: 15% szans na rechot na końcu)
/obj/item/organ/tongue/amphibian/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(!message || message[1] == "*")
		return
	speech_args[SPEECH_MESSAGE] = amphibian_speech(message)

/// Podwaja każde „r” (przed małą literą wielkie „R” zostaje „Rr”) i czasem dokleja rechot
/proc/amphibian_speech(message)
	var/list/out = list()
	var/length = length_char(message)
	for(var/i in 1 to length)
		var/letter = copytext_char(message, i, i + 1)
		if(letter == "r")
			out += "rr"
		else if(letter == "R")
			var/next = (i < length) ? copytext_char(message, i + 1, i + 2) : ""
			out += (next && lowertext(next) == next && uppertext(next) != next) ? "Rr" : "RR"
		else
			out += letter
	. = jointext(out, "")
	if(prob(15))
		. += pick(" rech", " kum", " brp", " łeh", " burup")

// Emotki (Goon /datum/mutantrace/frog/emote)

/datum/emote/living/carbon/human/scream/select_message_type(mob/user, intentional)
	. = ..()
	if(isamphibian(user) && !user.mind?.miming && !user.is_muzzled())
		return "wydaje okropny dźwięk!"

/datum/emote/living/carbon/human/scream/get_sound(mob/living/user)
	if(isamphibian(user) && !user.mind?.miming)
		return pick_emote_sound(user, list('aquila/sound/species/amphibian/scream1.ogg', 'aquila/sound/species/amphibian/scream3.ogg', 'aquila/sound/species/amphibian/scream4.ogg'))
	return ..()

/datum/emote/living/burp/select_message_type(mob/user, intentional)
	. = ..()
	if(isamphibian(user) && . == message)
		return "rechocze"

/datum/emote/living/burp/get_sound(mob/living/user)
	if(isamphibian(user))
		return 'aquila/sound/species/amphibian/croak.ogg'
	return ..()

/// Żaba zamiast bąka rechocze (Goon: „burp” i „fart” to u żaby rechot)
/datum/emote/living/carbon/human/fart/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(isamphibian(user))
		return FALSE
	return ..()

/datum/emote/living/carbon/human/amphibian_croak
	key = "fart"
	key_third_person = "farts"
	name = "zarechocz"
	message = "rechocze"
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	sound = 'aquila/sound/species/amphibian/croak.ogg'
	sound_volume = 60
	vary = TRUE

/datum/emote/living/carbon/human/amphibian_croak/can_run_emote(mob/user, status_check = TRUE, intentional)
	return isamphibian(user) && ..()

// Lepki język (Goon bioEffect „stickytongue”, wrodzony u żaby)

/datum/action/cooldown/mob_cooldown/sticky_tongue
	name = "Lepki język"
	desc = "Wystrzel język i przyciągnij nim przedmiot z odległości do 4 kratek. Owady połykasz w całości, a jedzenie od razu zjadasz."
	icon_icon = AMPHIBIAN_TONGUE_ICON
	button_icon_state = "sticky_tongue"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED // nie z ogłuszenia ani w kajdankach
	cooldown_time = 10 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/sticky_tongue/Activate(atom/target)
	var/mob/living/carbon/human/frog = owner
	if(!istype(frog) || !target)
		return FALSE
	if(!frog.get_bodypart(BODY_ZONE_HEAD))
		to_chat(frog, "<span class='warning'>Nie masz głowy!</span>")
		return FALSE
	var/obj/item/cover = mouth_cover(frog)
	if(cover)
		frog.visible_message("<span class='warning'>Język [frog] przykleja się do [cover.name]!</span>", "<span class='userdanger'>Twój język przykleja się do [cover.name]!</span>")
		StartCooldown()
		return TRUE
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return FALSE
	frog.setDir(get_dir(frog, target_turf))
	playsound(frog, 'aquila/sound/species/amphibian/tongue_shot.ogg', 40, TRUE)
	frog.add_movespeed_modifier(MOVESPEED_ID_AMPHIBIAN_TONGUE, update = TRUE, priority = 100, override = TRUE, multiplicative_slowdown = 1)
	addtimer(CALLBACK(frog, TYPE_PROC_REF(/mob, remove_movespeed_modifier), MOVESPEED_ID_AMPHIBIAN_TONGUE), 2 SECONDS)
	StartCooldown()
	// Za daleko albo za ścianą: język leci do końca zasięgu i wraca pusty
	var/in_reach = get_dist(frog, target_turf) <= AMPHIBIAN_TONGUE_RANGE && (target_turf in view(AMPHIBIAN_TONGUE_RANGE, frog))
	if(!in_reach)
		var/turf/end = get_turf(frog)
		for(var/i in 1 to AMPHIBIAN_TONGUE_RANGE)
			var/turf/next = get_step(end, get_dir(end, target_turf))
			if(!next || next.density)
				break
			end = next
		frog.Beam(end, icon_state = "tongue", icon = AMPHIBIAN_TONGUE_ICON, time = 3)
		return TRUE
	frog.Beam(target_turf, icon_state = "tongue", icon = AMPHIBIAN_TONGUE_ICON, time = 3)
	var/atom/movable/prize = pick_prize(target, target_turf)
	if(!prize)
		return TRUE
	playsound(prize, 'aquila/sound/species/amphibian/tongue_snap.ogg', 40, TRUE)
	if(isliving(prize))
		swallow_insect(frog, prize)
		return TRUE
	prize.visible_message("<span class='notice'>Język przykleja się do [prize] i ściąga go z powrotem!</span>")
	// Bez rzutu w żabę: rzucony przedmiot raniłby ją siłą rzutu, a zlewka chlapałaby zawartością
	prize.forceMove(get_turf(frog))
	if(IS_EDIBLE(prize))
		INVOKE_ASYNC(prize, TYPE_PROC_REF(/obj/item, attack), frog, frog)
	else
		frog.put_in_hands(prize)
	return TRUE

/// Maska albo hełm zasłaniające usta
/datum/action/cooldown/mob_cooldown/sticky_tongue/proc/mouth_cover(mob/living/carbon/human/frog)
	if(frog.wear_mask && (frog.wear_mask.flags_cover & MASKCOVERSMOUTH))
		return frog.wear_mask
	if(frog.head && (frog.head.flags_cover & HEADCOVERSMOUTH))
		return frog.head
	return null

/// Co przyklei się do języka: kliknięty przedmiot albo owad, a gdy kliknięto kratkę, pierwszy taki na niej
/datum/action/cooldown/mob_cooldown/sticky_tongue/proc/pick_prize(atom/target, turf/target_turf)
	if(can_grab(target))
		return target
	for(var/atom/movable/candidate in target_turf)
		if(can_grab(candidate))
			return candidate
	return null

/datum/action/cooldown/mob_cooldown/sticky_tongue/proc/can_grab(atom/movable/candidate)
	if(!istype(candidate) || candidate == owner || !isturf(candidate.loc))
		return FALSE
	if(isliving(candidate))
		var/mob/living/bug = candidate
		// Owad z graczem (eliksir rozumu, admin) nie jest przekąską
		return is_type_in_typecache(bug, GLOB.amphibian_edible_insects) && bug.stat != DEAD && !bug.mind && !bug.key
	return isitem(candidate) && !candidate.anchored

/// Goon throw_eat/insects: owad znika w żabie od razu
/datum/action/cooldown/mob_cooldown/sticky_tongue/proc/swallow_insect(mob/living/carbon/human/frog, mob/living/bug)
	frog.visible_message("<span class='warning'>[frog] połyka [bug] w całości!</span>", "<span class='notice'>Połykasz [bug] w całości!</span>")
	playsound(frog, 'sound/items/eatfood.ogg', 80, TRUE)
	bug.reagents?.trans_to(frog, bug.reagents.total_volume)
	frog.adjust_nutrition(20)
	log_combat(frog, bug, "swallowed (sticky tongue)")
	qdel(bug)
	addtimer(CALLBACK(frog, TYPE_PROC_REF(/mob, emote), "burp"), 2 SECONDS)

// Okno wyboru gatunku

/datum/preference/choiced/goon_variant/amphibian_skin
	db_key = "feature_amphibian_skin"
	feature_key = FEATURE_AMPHIBIAN_SKIN
	relevant_mutant_bodypart = FEATURE_AMPHIBIAN_SKIN
	main_feature_name = "Skóra"
	icon_file = AMPHIBIAN_BODYPARTS_ICON
	state_prefix = "amphibian"
	variant_list = "amphibian_skins"

/datum/species/amphibian/get_species_description()
	return "Niełatwo być zielonym. Albo żółtym, niebieskawym czy rdzawym."

/datum/species/amphibian/get_species_lore()
	return list(
		"Żaboludzie trafiają na stacje Nanotrasen z wilgotnych światów, na których najlepsze posady dostaje ten, \
		kto najdalej skoczy i najszybciej złapie muchę. Na suchym pokładzie człapią powoli i narzekają na klimatyzację.",

		"W wodzie za to rozkwitają: oddychają pod nią, nie spowalnia ich żadna kałuża, a skóra pije wszystko, w czym stoją. \
		Wszystko, także to, czego wolałyby nie pić.",
	)

/datum/species/amphibian/create_pref_unique_perks()
	return list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "water",
			SPECIES_PERK_NAME = "Płaz",
			SPECIES_PERK_DESC = "Nie toniesz i ciecze na podłodze cię nie spowalniają.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Gruba skóra",
			SPECIES_PERK_DESC = "Obrażenia fizyczne są o 30% mniejsze.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bug",
			SPECIES_PERK_NAME = "Lepki język",
			SPECIES_PERK_DESC = "Przyciągasz językiem przedmioty z odległości 4 kratek. Owady połykasz, a jedzenie od razu zjadasz.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = "Chłonna skóra",
			SPECIES_PERK_DESC = "Skóra wchłania ciecz, w której stoisz, chyba że masz szczelny strój. Trucizny też.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "biohazard",
			SPECIES_PERK_NAME = "Wrażliwość",
			SPECIES_PERK_DESC = "Toksyny szkodzą ci dwa razy bardziej, a oparzenia o 30% bardziej.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "shoe-prints",
			SPECIES_PERK_NAME = "Człapanie",
			SPECIES_PERK_DESC = "Na lądzie poruszasz się wyraźnie wolniej niż inni.",
		),
	)

// Części ciała: stany amphibian_[odmiana]_[część], odmianę ustawia update_limb() (goon_species.dm)

/obj/item/bodypart/head/amphibian
	icon = AMPHIBIAN_BODYPARTS_ICON
	static_icon = AMPHIBIAN_BODYPARTS_ICON
	icon_state = "amphibian_frog_head"
	limb_id = "amphibian_frog"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	goon_variant_feature = FEATURE_AMPHIBIAN_SKIN
	goon_variant_prefix = "amphibian"
	goon_variant_list = "amphibian_skins"

/obj/item/bodypart/chest/amphibian
	icon = AMPHIBIAN_BODYPARTS_ICON
	static_icon = AMPHIBIAN_BODYPARTS_ICON
	icon_state = "amphibian_frog_chest"
	limb_id = "amphibian_frog"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	goon_variant_feature = FEATURE_AMPHIBIAN_SKIN
	goon_variant_prefix = "amphibian"
	goon_variant_list = "amphibian_skins"

/obj/item/bodypart/l_arm/amphibian
	icon = AMPHIBIAN_BODYPARTS_ICON
	static_icon = AMPHIBIAN_BODYPARTS_ICON
	icon_state = "amphibian_frog_l_arm"
	limb_id = "amphibian_frog"
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	goon_variant_feature = FEATURE_AMPHIBIAN_SKIN
	goon_variant_prefix = "amphibian"
	goon_variant_list = "amphibian_skins"

/obj/item/bodypart/r_arm/amphibian
	icon = AMPHIBIAN_BODYPARTS_ICON
	static_icon = AMPHIBIAN_BODYPARTS_ICON
	icon_state = "amphibian_frog_r_arm"
	limb_id = "amphibian_frog"
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	goon_variant_feature = FEATURE_AMPHIBIAN_SKIN
	goon_variant_prefix = "amphibian"
	goon_variant_list = "amphibian_skins"

/obj/item/bodypart/l_leg/amphibian
	icon = AMPHIBIAN_BODYPARTS_ICON
	static_icon = AMPHIBIAN_BODYPARTS_ICON
	icon_state = "amphibian_frog_l_leg"
	limb_id = "amphibian_frog"
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	goon_variant_feature = FEATURE_AMPHIBIAN_SKIN
	goon_variant_prefix = "amphibian"
	goon_variant_list = "amphibian_skins"

/obj/item/bodypart/r_leg/amphibian
	icon = AMPHIBIAN_BODYPARTS_ICON
	static_icon = AMPHIBIAN_BODYPARTS_ICON
	icon_state = "amphibian_frog_r_leg"
	limb_id = "amphibian_frog"
	should_draw_greyscale = FALSE
	uses_mutcolor = FALSE
	goon_variant_feature = FEATURE_AMPHIBIAN_SKIN
	goon_variant_prefix = "amphibian"
	goon_variant_list = "amphibian_skins"

#undef AMPHIBIAN_SLOWDOWN
#undef AMPHIBIAN_BLOOD_COLOR
#undef AMPHIBIAN_ABSORB_AMOUNT
#undef AMPHIBIAN_TONGUE_RANGE
#undef AMPHIBIAN_TONGUE_ICON
#undef MOVESPEED_ID_AMPHIBIAN_TONGUE
