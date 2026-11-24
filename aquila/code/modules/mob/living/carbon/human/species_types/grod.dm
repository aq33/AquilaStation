// Grod: port BeeStation/BeeStation-Hornet#7202 (kontynuacja BeeStation/BeeStation-Hornet#5442, oba niescalone w Bee).
// Koncepcja i sprite'y: Naevi, Pirill, Troontjelolo, ThomasTheDOOT, MrEloda, SynergyJohn (CC-BY-SA 3.0).
// Czapki spoza cylindrów, krew na ubraniach, kajdanki, facehugger, plecak odkrywcy, kokon i strąk w tacy (grod_extras.dmi):
// z folderu twórczyni na Dysku Google projektu Grod revival, ci sami autorzy i ta sama licencja.
// Kod oryginału: Kapu1178, Rac-off, DrDuckedGoose (AGPL). U nas napisany od nowa w aquila/, bez zmian w core.
//
// Grod to korona (krucha, rozumna istota) w ciele dużej gąsienicy. Ciało bez korony nie żyje:
// - korona jest mózgiem (/obj/item/organ/brain/grod), rysujemy ją na głowie z wybranym kształtem;
// - korona może opuścić ciało jako pająk-korona i przejąć ciało bez mózgu (grod_crown.dm);
// - postawa ruchu (dwie ręce, szybciej) i postawa pracy (cztery ręce, wolniej) z Bee#5442 (grod_stance.dm);
// - korona w ciele innej rasy przemienia je w kokonie, a posadzona w tacy wyrasta w nowe ciało (grod_cocoon.dm);
// - Grod nosi tylko to, co ma narysowane we własnych sprite'ach (kamizelki, cylindry, buty, rękawice...).
//   Nasze ubrania mapujemy na jego sprite'y tabelą nazw, a reszta slotów przyjmuje rzeczy ze zwykłym wyglądem.

// Akcesoria: korona, wzory i ogon. Nazwy angielskie zostają kluczami w zapisach postaci, polskie są do wyświetlania.

/datum/sprite_accessory/grod_crown
	icon = GROD_ICON_CROWNS
	color_src = MUTCOLORS

/datum/sprite_accessory/grod_crown/antenna
	name = "Antenna"
	icon_state = "antenna"

/datum/sprite_accessory/grod_crown/asymmetric
	name = "Asymmetric"
	icon_state = "asymmetric"

/datum/sprite_accessory/grod_crown/aureole
	name = "Aureole"
	icon_state = "aureole"

/datum/sprite_accessory/grod_crown/coronet
	name = "Coronet"
	icon_state = "coronet"

/datum/sprite_accessory/grod_crown/crown
	name = "Crown"
	icon_state = "crown"

/datum/sprite_accessory/grod_crown/diadem
	name = "Diadem"
	icon_state = "diadem"

/datum/sprite_accessory/grod_crown/garland
	name = "Garland"
	icon_state = "garland"

/datum/sprite_accessory/grod_crown/krone
	name = "Krone"
	icon_state = "krone"

/datum/sprite_accessory/grod_crown/reflector
	name = "Reflector"
	icon_state = "reflector"

/datum/sprite_accessory/grod_crown/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/grod_crown/royalist
	name = "Royalist"
	icon_state = "royalist"

/datum/sprite_accessory/grod_crown/sapling
	name = "Sapling"
	icon_state = "sapling"

/datum/sprite_accessory/grod_crown/sprout
	name = "Sprout"
	icon_state = "sprout"

/datum/sprite_accessory/grod_crown/tiara
	name = "Tiara"
	icon_state = "tiara"

/datum/sprite_accessory/grod_crown/wreath
	name = "Wreath"
	icon_state = "wreath"

/datum/sprite_accessory/grod_crown/youngling
	name = "Youngling"
	icon_state = "youngling"

/datum/sprite_accessory/grod_marks
	icon = GROD_ICON_MARKINGS
	color_src = 0

/datum/sprite_accessory/grod_marks/none
	name = "None"
	icon_state = null

/datum/sprite_accessory/grod_marks/atalanta
	name = "Atalanta"
	icon_state = "atalanta"

/datum/sprite_accessory/grod_marks/cardui
	name = "Cardui"
	icon_state = "cardui"

/datum/sprite_accessory/grod_marks/cerura
	name = "Cerura"
	icon_state = "cerura"

/datum/sprite_accessory/grod_marks/claudia
	name = "Claudia"
	icon_state = "claudia"

/datum/sprite_accessory/grod_marks/eacles
	name = "Eacles"
	icon_state = "eacles"

/datum/sprite_accessory/grod_marks/harrisii
	name = "Harrisii"
	icon_state = "harrisii"

/datum/sprite_accessory/grod_marks/oblinita
	name = "Oblinita"
	icon_state = "oblinita"

/datum/sprite_accessory/grod_marks/promethea
	name = "Promethea"
	icon_state = "promethea"

/datum/sprite_accessory/grod_marks/tussock
	name = "Tussock"
	icon_state = "tussock"

/datum/sprite_accessory/grod_marks/vanillae
	name = "Vanillae"
	icon_state = "vanillae"

/datum/sprite_accessory/grod_marks/xestia
	name = "Xestia"
	icon_state = "xestia"

/datum/sprite_accessory/grod_tail
	icon = GROD_ICON_TAILS
	color_src = MUTCOLORS

/datum/sprite_accessory/grod_tail/regular
	name = "Regular"
	icon_state = "regular"

/datum/sprite_accessory/grod_tail/cobra
	name = "Cobra"
	icon_state = "cobra"

/datum/sprite_accessory/grod_tail/hopper
	name = "Hopper"
	icon_state = "hopper"

/datum/sprite_accessory/grod_tail/hornet
	name = "Hornet"
	icon_state = "hornet"

/datum/sprite_accessory/grod_tail/hugger
	name = "Hugger"
	icon_state = "hugger"

/datum/sprite_accessory/grod_tail/leaf
	name = "Leaf"
	icon_state = "leaf"

/datum/sprite_accessory/grod_tail/prolonged
	name = "Prolonged"
	icon_state = "prolonged"

/datum/sprite_accessory/grod_tail/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/grod_tail/snail
	name = "Snail"
	icon_state = "snail"

/datum/sprite_accessory/grod_tail/spiky
	name = "Spiky"
	icon_state = "spiky"

/datum/sprite_accessory/grod_tail/twins
	name = "Twins"
	icon_state = "twins"

/proc/grod_accessory_list(prototype)
	var/list/output = list()
	init_sprite_accessory_subtypes(prototype, output)
	return output

GLOBAL_LIST_INIT(grod_crowns_list, grod_accessory_list(/datum/sprite_accessory/grod_crown))
GLOBAL_LIST_INIT(grod_marks_list, grod_accessory_list(/datum/sprite_accessory/grod_marks))
GLOBAL_LIST_INIT(grod_tails_list, grod_accessory_list(/datum/sprite_accessory/grod_tail))

/// Polskie nazwy akcesoriów Groda w oknie postaci
GLOBAL_LIST_INIT(grod_accessory_names, list(
	"Antenna" = "Czułki",
	"Asymmetric" = "Asymetryczna",
	"Aureole" = "Aureola",
	"Coronet" = "Korona książęca",
	"Crown" = "Korona",
	"Diadem" = "Diadem",
	"Garland" = "Girlanda",
	"Krone" = "Krone",
	"Reflector" = "Odbłyśnik",
	"Royal" = "Królewska",
	"Royalist" = "Rojalistyczna",
	"Sapling" = "Sadzonka",
	"Sprout" = "Kiełek",
	"Tiara" = "Tiara",
	"Wreath" = "Wieniec",
	"Youngling" = "Młodzik",
	"None" = "Brak",
	"Atalanta" = "Atalanta",
	"Cardui" = "Osetnik",
	"Cerura" = "Widłogonka",
	"Claudia" = "Klaudia",
	"Eacles" = "Eacles",
	"Harrisii" = "Harrisii",
	"Oblinita" = "Oblinita",
	"Promethea" = "Prometeja",
	"Tussock" = "Brudnica",
	"Vanillae" = "Wanilia",
	"Xestia" = "Xestia",
	"Regular" = "Zwykły",
	"Cobra" = "Kobra",
	"Hopper" = "Skoczek",
	"Hornet" = "Szerszeń",
	"Hugger" = "Przytulacz",
	"Leaf" = "Liść",
	"Prolonged" = "Wydłużony",
	"Snail" = "Ślimak",
	"Spiky" = "Kolczasty",
	"Twins" = "Bliźniaczy",
))

// Rasa

/datum/species/grod
	name = "Grod"
	id = SPECIES_GROD
	sexes = FALSE
	default_color = "3fae3f"
	species_traits = list(NO_DNA_COPY, AGENDER, NOHUSK, NO_UNDERWEAR, NOEYESPRITES, MUTCOLORS)
	inherent_traits = list(TRAIT_RESISTLOWPRESSURE, TRAIT_NOSLIPWATER)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	mutant_bodyparts = list("grod_crown", "grod_marks", "grod_tail")
	default_features = list("mcolor" = "3fae3f", "grod_crown" = "Crown", "grod_marks" = "None", "grod_marks_color" = "e8e04a", "grod_tail" = "Regular")
	mutanttongue = /obj/item/organ/tongue/grod
	mutant_brain = /obj/item/organ/brain/grod
	brutemod = 1.1
	burnmod = 1.2
	heatmod = 1.3
	coldmod = 0.7
	toxmod = 0.8
	staminamod = GROD_STAMINAMOD
	speedmod = GROD_SPEEDMOD
	species_language_holder = /datum/language_holder/grod
	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,0), OFFSET_EARS = list(0,0), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))
	/// Grod nie ma nóg: z przodu i z tyłu w chodzie ruszają się tylko ręce (walk_animation.dm)
	walk_animation_legs = FALSE
	changesource_flags = MIRROR_BADMIN | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	species_chest = /obj/item/bodypart/chest/grod
	species_head = /obj/item/bodypart/head/grod
	species_l_arm = /obj/item/bodypart/l_arm/grod
	species_r_arm = /obj/item/bodypart/r_arm/grod
	species_l_leg = /obj/item/bodypart/l_leg/grod
	species_r_leg = /obj/item/bodypart/r_leg/grod
	/// Akcja odłączenia korony
	var/datum/action/innate/grod_crownspider/crownspider
	/// Akcja zmiany postawy (grod_stance.dm)
	var/datum/action/innate/grod_stance/stance_action
	/// Obecna postawa: GROD_STANCE_MOBILE albo GROD_STANCE_INTERACT
	var/stance = GROD_STANCE_MOBILE
	/// Kierunek, dla którego rysujemy rzeczy w dłoniach (sygnał obrotu przychodzi przed zmianą dir)
	var/hands_render_dir

/mob/living/carbon/human/species/grod
	race = /datum/species/grod

/// Imię jak u Grodów: grecka litera, apostrof, sylaba i przydomek (Eta'Thra Boski)
/datum/species/grod/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.grod_first)]'[pick(GLOB.grod_middle)] [lastname || pick(GLOB.grod_last)]"
	if(unique && attempts < 10 && findname(.))
		return random_name(gender, TRUE, lastname, attempts + 1)

GLOBAL_LIST_INIT(grod_first, world.file2list("strings/names/grod_first.txt"))
GLOBAL_LIST_INIT(grod_middle, world.file2list("strings/names/grod_middle.txt"))
GLOBAL_LIST_INIT(grod_last, world.file2list("strings/names/grod_last.txt"))

/datum/species/grod/on_species_gain(mob/living/carbon/human/C, datum/species/old_species, pref_load)
	. = ..()
	if(!istype(C))
		return
	// Postać bez zapisanych cech Groda (spawn admina, zmiana rasy) dostaje domyślne, żeby korona i ogon były widoczne
	for(var/feature in default_features)
		if(!C.dna.features[feature])
			C.dna.features[feature] = default_features[feature]
	C.update_body()
	stance = GROD_STANCE_MOBILE
	grod_set_hands(C, 2)
	if(!crownspider)
		crownspider = new
	crownspider.Grant(C)
	if(!stance_action)
		stance_action = new
	stance_action.Grant(C)
	RegisterSignal(C, COMSIG_ATOM_DIR_CHANGE, PROC_REF(grod_dir_changed))
	// Ubrania bez sprite'u Groda spadają (zmiana rasy w trakcie gry)
	for(var/slot in list(ITEM_SLOT_OCLOTHING, ITEM_SLOT_SUITSTORE, ITEM_SLOT_ICLOTHING, ITEM_SLOT_HEAD, ITEM_SLOT_FEET, ITEM_SLOT_GLOVES, ITEM_SLOT_NECK))
		var/obj/item/worn = C.get_item_by_slot(slot)
		if(worn && !grod_can_wear(worn, slot))
			C.dropItemToGround(worn)

/datum/species/grod/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	grod_set_stance(C, GROD_STANCE_MOBILE, TRUE)
	grod_set_hands(C, 2)
	UnregisterSignal(C, COMSIG_ATOM_DIR_CHANGE)
	if(crownspider)
		crownspider.Remove(C)
		QDEL_NULL(crownspider)
	if(stance_action)
		stance_action.Remove(C)
		QDEL_NULL(stance_action)

/// Druga para rąk w postawie pracy: dłonie 3 i 4 są na odnóżach (held_index nóg Groda).
/// Ciało dokłada ich części przy podpięciu kończyn, a tu poszerzamy listę trzymanych rzeczy i sloty dłoni w HUD-zie.
/datum/species/grod/proc/grod_set_hands(mob/living/carbon/human/C, amount)
	if(length(C.held_items) > amount)
		for(var/index in length(C.held_items) to amount + 1 step -1)
			C.dropItemToGround(C.held_items[index], TRUE)
	C.held_items.len = amount
	if(C.active_hand_index > amount)
		C.swap_hand(1)
	if(C.hud_used)
		C.hud_used.build_hand_slots()
		C.hud_used.show_hud(C.hud_used.hud_version)

/datum/species/grod/Destroy()
	QDEL_NULL(crownspider)
	QDEL_NULL(stance_action)
	return ..()

/// Środki chwastobójcze trują Groda
/datum/species/grod/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(istype(chem, /datum/reagent/toxin/plantbgone))
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	if(istype(chem, /datum/reagent/toxin/pestkiller))
		H.adjustToxLoss(2)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()

/datum/emote/living/carbon/human/scream/get_sound(mob/living/user)
	if(isgrod(user) && !user.mind?.miming)
		return pick_emote_sound(user, list('aquila/sound/voice/grod/grod_scream_1.ogg', 'aquila/sound/voice/grod/grod_scream_2.ogg'))
	return ..()

// Wygląd: korona (za i przed głową), wzory i ogon. Rdzeń rysuje tylko swoje akcesoria, więc dokładamy nasze na te same warstwy.

/datum/species/grod/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	. = ..()
	grod_draw_parts(H)

/datum/species/grod/proc/grod_draw_parts(mob/living/carbon/human/H)
	var/list/behind = list()
	var/list/adjacent = list()
	var/list/front = list()
	var/body_color = "#[H.dna.features["mcolor"] || default_color]"
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	// Korona tylko na głowie, w której jest (bez niej Grod to pusta skorupa), i nie pod czapką
	if(head && istype(H.getorganslot(ORGAN_SLOT_BRAIN), /obj/item/organ/brain/grod) && !(H.head?.flags_inv & HIDEHAIR))
		var/datum/sprite_accessory/crown = GLOB.grod_crowns_list[H.dna.features["grod_crown"]]
		if(crown?.icon_state)
			behind += grod_part_image(crown, "m_grod_crown_[crown.icon_state]_BEHIND", BODY_BEHIND_LAYER, body_color)
			front += grod_part_image(crown, "m_grod_crown_[crown.icon_state]_FRONT", BODY_FRONT_LAYER, body_color)
	var/datum/sprite_accessory/marks = GLOB.grod_marks_list[H.dna.features["grod_marks"]]
	if(marks?.icon_state)
		adjacent += grod_part_image(marks, "m_grod_marks_[marks.icon_state]_ADJ", BODY_ADJ_LAYER, "#[H.dna.features["grod_marks_color"] || "e8e04a"]")
	var/datum/sprite_accessory/tail = GLOB.grod_tails_list[H.dna.features["grod_tail"]]
	if(tail?.icon_state && H.get_bodypart(BODY_ZONE_CHEST))
		adjacent += grod_part_image(tail, "m_grod_tail_[tail.icon_state]_ADJ", BODY_ADJ_LAYER, body_color)
	grod_add_to_layer(H, BODY_BEHIND_LAYER, behind)
	grod_add_to_layer(H, BODY_ADJ_LAYER, adjacent)
	grod_add_to_layer(H, BODY_FRONT_LAYER, front)

/datum/species/grod/proc/grod_part_image(datum/sprite_accessory/accessory, state, layer, color)
	var/mutable_appearance/part = mutable_appearance(accessory.icon, state, -layer)
	part.color = color
	return part

/// Dokłada nakładki do warstwy, którą rdzeń już ustawił w handle_mutant_bodyparts
/datum/species/grod/proc/grod_add_to_layer(mob/living/carbon/human/H, layer, list/additions)
	if(!length(additions))
		return
	var/list/standing = H.overlays_standing[layer]
	if(standing && !islist(standing))
		standing = list(standing)
	var/list/combined = standing ? standing.Copy() : list()
	H.remove_overlay(layer)
	H.overlays_standing[layer] = combined + additions
	H.apply_overlay(layer)

// Części ciała: szare sprite'y barwione kolorem ciała

/obj/item/bodypart/head/grod
	icon = GROD_ICON_BODY
	static_icon = GROD_ICON_BODY
	limb_id = SPECIES_GROD
	is_dimorphic = FALSE
	should_draw_greyscale = TRUE

/obj/item/bodypart/chest/grod
	icon = GROD_ICON_BODY
	static_icon = GROD_ICON_BODY
	limb_id = SPECIES_GROD
	is_dimorphic = FALSE
	should_draw_greyscale = TRUE

/obj/item/bodypart/l_arm/grod
	icon = GROD_ICON_BODY
	static_icon = GROD_ICON_BODY
	limb_id = SPECIES_GROD
	should_draw_greyscale = TRUE

/obj/item/bodypart/r_arm/grod
	icon = GROD_ICON_BODY
	static_icon = GROD_ICON_BODY
	limb_id = SPECIES_GROD
	should_draw_greyscale = TRUE

/obj/item/bodypart/l_leg/grod
	name = "lewe odnóża"
	icon = GROD_ICON_BODY
	static_icon = GROD_ICON_BODY
	limb_id = SPECIES_GROD
	should_draw_greyscale = TRUE
	held_index = 3

/obj/item/bodypart/r_leg/grod
	name = "prawe odnóża"
	icon = GROD_ICON_BODY
	static_icon = GROD_ICON_BODY
	limb_id = SPECIES_GROD
	should_draw_greyscale = TRUE
	held_index = 4

/obj/item/organ/tongue/grod
	name = "rozwidlony język"
	desc = "Dziwnie rozwidlony, owadzi język."
	icon_state = "tonguefly"
	say_mod = "oznajmia"
	liked_food = VEGETABLES | GRAIN | FRUIT
	disliked_food = DAIRY
	toxic_food = TOXIC | MEAT | RAW

/obj/item/organ/tongue/grod/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible.Copy()
	languages_possible[/datum/language/pohlan] = TRUE // typecache: is_type_in_typecache czyta L[typ]

// Ubrania: Grod nosi tylko to, co ma narysowane. Sloty potrzebne do życia (plecak, pas, słuchawki, maska, okulary, identyfikator)
// przyjmują wszystko, a bez sprite'u Groda rzecz wygląda jak na człowieku.

/// Warstwa ubrania -> część z get_custom_icons()
GLOBAL_LIST_INIT(grod_layer_parts, list(
	"[UNIFORM_LAYER]" = "uniform",
	"[ID_LAYER]" = "generic",
	"[GLOVES_LAYER]" = "gloves",
	"[SHOES_LAYER]" = "shoes",
	"[EARS_LAYER]" = "ears",
	"[GLASSES_LAYER]" = "glasses",
	"[BELT_LAYER]" = "belt",
	"[NECK_LAYER]" = "neck",
	"[BACK_LAYER]" = "back",
	"[FACEMASK_LAYER]" = "mask",
	"[HEAD_LAYER]" = "head",
))

/// Slot -> część z get_custom_icons() oraz czy bez sprite'u Groda rzecz da się założyć
GLOBAL_LIST_INIT(grod_slot_parts, list(
	"[ITEM_SLOT_ICLOTHING]" = list("uniform", FALSE),
	"[ITEM_SLOT_HEAD]" = list("head", FALSE),
	"[ITEM_SLOT_FEET]" = list("shoes", FALSE),
	"[ITEM_SLOT_GLOVES]" = list("gloves", FALSE),
	"[ITEM_SLOT_NECK]" = list("neck", FALSE),
	"[ITEM_SLOT_ID]" = list("generic", TRUE),
	"[ITEM_SLOT_EARS]" = list("ears", TRUE),
	"[ITEM_SLOT_EYES]" = list("glasses", TRUE),
	"[ITEM_SLOT_BELT]" = list("belt", TRUE),
	"[ITEM_SLOT_BACK]" = list("back", TRUE),
	"[ITEM_SLOT_MASK]" = list("mask", TRUE),
))

/// Nasze stany ubrań -> stany w sprite'ach Groda (jego pliki mają nazwy z BeeStation)
GLOBAL_LIST_INIT(grod_state_map, list(
	// uniformy: kamizelki działów
	"jumpsuit" = "grey",
	"legacy_atmos" = "atmos",
	"legacy_chiefengineer" = "ce",
	"rhos" = "hos",
	"barman" = "bartender",
	"sutanna" = "chaplain",
	"chef" = "cook",
	"red_suit" = "curator",
	"virology" = "virologywhite",
	"security" = "rsecurity",
	"explorer" = "miner",
	"officer" = "darkblue",
	"camogreen" = "darkgreen",
	"tactifool" = "black",
	"scisuit" = "toxinswhite",
	"solgov_medsci" = "white",
	"solgov_engsec" = "orange",
	"solgov_command" = "darkblue",
	"solgov_pilot" = "khaki",
	"solgov_cadet" = "grey",
	"bitrunner" = "purple",
	"clown_uniform" = "clown",
	// buty
	"brown_laceups" = "laceups",
	"clown_shoes" = "clown",
	// plecaki
	"satchel-norm" = "backpack",
	"satchel" = "backpack",
	"duffel-norm" = "duffel",
	"duffel" = "duffel",
	// słuchawki
	"srv_headset" = "headset",
	"med_headset" = "headset",
	"eng_headset" = "headset",
	"sci_headset" = "headset",
	"mine_headset" = "headset",
	"cargo_headset" = "headset",
	"sec_headset" = "headset",
	"medsci_headset" = "headset",
	"srvsec_headset" = "headset",
	"medsec_headset" = "headset",
	"mun_headset" = "headset",
	"mun_headset_alt" = "headset",
	// maski
	"gas_alt" = "gasmask",
	"sechailer" = "gasmask",
	// czapki z Dysku twórczyni
	"hardhat0_yellow" = "hardhat_yellow",
	"hardhat1_yellow" = "hardhat_yellow",
	"hardhat0_orange" = "hardhat_orange",
	"hardhat1_orange" = "hardhat_orange",
	"hardhat0_white" = "hardhat_white",
	"hardhat1_white" = "hardhat_white",
	"santahatnorm" = "santa",
	"ushankadown" = "ushanka",
	"ushankaup" = "ushanka",
	"rus_ushanka" = "ushanka",
	"beret_cmo" = "beretcmo",
))

/// Uniformy, których stan nie mówi nic o wyglądzie (różne przedmioty z tym samym stanem): typ -> stan Groda
GLOBAL_LIST_INIT(grod_type_map, list(
	/obj/item/clothing/under/ship/marine = "khaki",
	/obj/item/clothing/under/ship/military_police = "rsecurity",
	/obj/item/clothing/under/rank/security/officer = "rsecurity",
	/obj/item/clothing/shoes/sneakers/white = "white",
	/obj/item/clothing/shoes/sneakers/brown = "brown",
	/obj/item/clothing/shoes/sneakers = "black",
))

/// Plik i stan sprite'u Groda dla przedmiotu w danej części ciała, albo null
/proc/grod_worn_sprite(obj/item/I, part, datum/species/grod/species)
	var/file = species.get_custom_icons(part)
	if(!file)
		return null
	for(var/type in GLOB.grod_type_map)
		if(istype(I, type) && icon_exists(file, GLOB.grod_type_map[type]))
			return list(file, GLOB.grod_type_map[type])
	var/state = I.worn_icon_state || I.icon_state
	if(icon_exists(file, state))
		return list(file, state)
	var/mapped = GLOB.grod_state_map[state]
	if(mapped && icon_exists(file, mapped))
		return list(file, mapped)
	if(part == "uniform" && icon_exists(file, "grey")) // każdy kombinezon bez odpowiednika to szara kamizelka
		return list(file, "grey")
	return null

/datum/species/grod/proc/grod_can_wear(obj/item/I, slot)
	if(slot == ITEM_SLOT_OCLOTHING || slot == ITEM_SLOT_SUITSTORE)
		return FALSE // Grod nie ma sprite'ów strojów wierzchnich (jak w Bee)
	var/list/rule = GLOB.grod_slot_parts["[slot]"]
	if(!rule || rule[2])
		return TRUE
	return !!grod_worn_sprite(I, rule[1], src)

/datum/species/grod/can_equip(obj/item/I, slot, disable_warning, mob/living/carbon/human/H, bypass_equip_delay_self = FALSE)
	if(!grod_can_wear(I, slot))
		if(!disable_warning)
			to_chat(H, "<span class='warning'>[I] nie pasuje na ciało Groda!</span>")
		return FALSE
	return ..()

/datum/species/grod/get_custom_icons(part)
	switch(part)
		if("uniform")
			return 'aquila/icons/mob/species/grod/onmob_grod_under.dmi'
		if("head")
			return 'aquila/icons/mob/species/grod/onmob_grod_head.dmi'
		if("mask")
			return 'aquila/icons/mob/species/grod/onmob_grod_mask.dmi'
		if("gloves")
			return 'aquila/icons/mob/species/grod/onmob_grod_gloves.dmi'
		if("ears")
			return 'aquila/icons/mob/species/grod/onmob_grod_ears.dmi'
		if("back")
			return 'aquila/icons/mob/species/grod/onmob_grod_back.dmi'
		if("shoes")
			return 'aquila/icons/mob/species/grod/onmob_grod_shoes.dmi'
		if("glasses")
			return 'aquila/icons/mob/species/grod/onmob_grod_glasses.dmi'
		if("neck")
			return 'aquila/icons/mob/species/grod/onmob_grod_neck.dmi'
		if("generic")
			return 'aquila/icons/mob/species/grod/onmob_grod_generic.dmi'
		if("belt")
			return 'aquila/icons/mob/species/grod/onmob_grod_belt.dmi'

/// Rzecz na Grodzie: jego sprite zamiast ludzkiego (DIGI_ICON_FILE_PASSED każe użyć podanego pliku zamiast worn_icon)
/obj/item/build_worn_icon(default_layer = 0, default_icon_file = null, isinhands = FALSE, femaleuniform = NO_FEMALE_UNIFORM, override_state = null, special_override_flags = NONE)
	if(!isinhands && ishuman(loc))
		var/mob/living/carbon/human/wearer = loc
		var/datum/species/grod/grod = wearer.dna?.species
		var/part = GLOB.grod_layer_parts["[default_layer]"]
		if(istype(grod) && part)
			var/list/sprite = grod_worn_sprite(src, part, grod)
			if(sprite)
				var/mutable_appearance/standing = ..(default_layer, sprite[1], FALSE, NO_FEMALE_UNIFORM, sprite[2], special_override_flags | DIGI_ICON_FILE_PASSED)
				grod_blood_overlays(standing)
				return standing
	return ..()

/// Krew na ubraniu Groda: ludzkie plamy z icons/effects/blood.dmi zamieniamy na rysunki dopasowane do jego ciała
/proc/grod_blood_overlays(mutable_appearance/standing)
	if(!length(standing?.overlays))
		return
	var/list/old_overlays = standing.overlays.Copy()
	standing.overlays.Cut()
	for(var/overlay in old_overlays)
		var/mutable_appearance/copy = new(overlay)
		if(copy.icon == 'icons/effects/blood.dmi' && icon_exists(GROD_ICON_EXTRAS, copy.icon_state))
			copy.icon = GROD_ICON_EXTRAS
		standing.overlays += copy

/// Kajdanki na odnóżach Groda
/mob/living/carbon/human/update_inv_handcuffed()
	. = ..()
	if(handcuffed && isgrod(src))
		var/mutable_appearance/cuffs = overlays_standing[HANDCUFF_LAYER]
		if(istype(cuffs))
			remove_overlay(HANDCUFF_LAYER)
			cuffs.icon = GROD_ICON_EXTRAS
			overlays_standing[HANDCUFF_LAYER] = cuffs
			apply_overlay(HANDCUFF_LAYER)

/// Kajdanki na nogi: plik „generic” Groda nie ma stanu legcuff1, więc bez tego byłyby niewidoczne
/mob/living/carbon/human/update_inv_legcuffed()
	. = ..()
	if(!legcuffed || !isgrod(src))
		return
	var/mutable_appearance/cuffs = overlays_standing[LEGCUFF_LAYER]
	if(istype(cuffs) && !icon_exists(cuffs.icon, cuffs.icon_state))
		remove_overlay(LEGCUFF_LAYER)
		cuffs.icon = 'icons/mob/mob.dmi'
		overlays_standing[LEGCUFF_LAYER] = cuffs
		apply_overlay(LEGCUFF_LAYER)

/// Zakrwawione dłonie Groda bez rękawic
/mob/living/carbon/human/update_inv_gloves()
	. = ..()
	if(!gloves && bloody_hands && isgrod(src))
		var/mutable_appearance/bloody_overlay = overlays_standing[GLOVES_LAYER]
		// Grod ma rysunek tylko obu zakrwawionych dłoni; wersje jednej dłoni zostają ludzkie
		if(istype(bloody_overlay) && bloody_overlay.icon == 'icons/effects/blood.dmi' && bloody_overlay.icon_state == "bloodyhands")
			remove_overlay(GLOVES_LAYER)
			bloody_overlay.icon = GROD_ICON_EXTRAS
			overlays_standing[GLOVES_LAYER] = bloody_overlay
			apply_overlay(GLOVES_LAYER)

// Cylindry Groda: kapelusz każdej profesji zakrywa koronę (zdjęcie go przy obcych to u Grodów tabu)

/obj/item/clothing/head/grodhat
	name = "cylinder Groda"
	desc = "Wysoki cylinder, pod którym Grod chowa koronę. Zdjęcie go przy obcych to u Grodów tabu."
	icon = 'aquila/icons/mob/species/grod/onmob_grod_head.dmi'
	icon_state = "grey"
	item_state = "grey"
	flags_inv = HIDEHAIR

/// Profesja -> stan cylindra
GLOBAL_LIST_INIT(grod_job_hats, list(
	JOB_NAME_CAPTAIN = "captain",
	JOB_NAME_HEADOFPERSONNEL = "hop",
	JOB_NAME_HEADOFSECURITY = "hos",
	JOB_NAME_WARDEN = "warden",
	JOB_NAME_DETECTIVE = "detective",
	JOB_NAME_SECURITYOFFICER = "sec",
	JOB_NAME_DEPUTY = "sec",
	JOB_NAME_BRIGPHYSICIAN = "brigphys",
	JOB_NAME_CHIEFENGINEER = "ce",
	JOB_NAME_STATIONENGINEER = "engi",
	JOB_NAME_ATMOSPHERICTECHNICIAN = "atmos",
	JOB_NAME_CHIEFMEDICALOFFICER = "cmo",
	JOB_NAME_MEDICALDOCTOR = "md",
	JOB_NAME_PARAMEDIC = "paramed",
	JOB_NAME_CHEMIST = "chem",
	JOB_NAME_GENETICIST = "gene",
	JOB_NAME_VIROLOGIST = "viro",
	JOB_NAME_PSYCHIATRIST = "md",
	JOB_NAME_RESEARCHDIRECTOR = "rd",
	JOB_NAME_SCIENTIST = "sci",
	JOB_NAME_ROBOTICIST = "robo",
	JOB_NAME_QUARTERMASTER = "qm",
	JOB_NAME_CARGOTECHNICIAN = "cargo",
	JOB_NAME_SHAFTMINER = "miner",
	JOB_NAME_JANITOR = "janitor",
	JOB_NAME_BOTANIST = "botany",
	JOB_NAME_COOK = "chef",
	JOB_NAME_BARTENDER = "barman",
	JOB_NAME_CHAPLAIN = "chaplain",
	JOB_NAME_CURATOR = "curator",
	JOB_NAME_CLOWN = "clown",
	JOB_NAME_MIME = "mime",
	JOB_NAME_BRIDGESTAFF = "darkblue",
	JOB_NAME_AIRTRAFFICCONTROLLER = "lightblue",
	JOB_NAME_PILOT = "khaki",
	JOB_NAME_MUNITIONSTECHNICIAN = "orange",
	JOB_NAME_DECKTECHNICIAN = "darkbrown",
	JOB_NAME_MASTERATARMS = "maroon",
	JOB_NAME_LAWYER = "black",
	JOB_NAME_VIP = "black",
	JOB_NAME_ASSISTANT = "grey",
))

/// Po wyposażeniu profesji Grod dostaje cylinder swojego działu (inne nakrycia głowy i tak nie pasują)
/datum/species/grod/after_equip_job(datum/job/J, mob/living/carbon/human/H, client/preference_source = null)
	. = ..()
	if(H.head)
		return
	var/obj/item/clothing/head/grodhat/hat = new(H)
	var/state = GLOB.grod_job_hats[J?.title]
	if(state)
		hat.icon_state = state
		hat.item_state = state
	if(!H.equip_to_slot_if_possible(hat, ITEM_SLOT_HEAD, disable_warning = TRUE))
		qdel(hat)

// Opis w oknie wyboru gatunku

/datum/species/grod/get_species_description()
	return "Grody to korony, kruche i bardzo inteligentne istoty, które żyją w ciałach dużych gąsienic. \
		Ciało bez korony nie żyje, a korona może je opuścić i poszukać nowego."

/datum/species/grod/get_species_lore()
	return list(
		"Grody powstały z symbiozy koron, rozumnych, ale słabych istot z odległej planety, z silnymi i odpornymi owadami. \
			Przez setki lat owady przejęły wiedzę koron, a korony nauczyły się wyhodować dla siebie ciało na wzór owadów \
			albo przejąć cudze. Dziś Grody przemierzają kosmos w swoich skorupach i zbierają wiedzę.",
		"Grody chowają koronę pod kapeluszem, a zdjęcie go przy innych rasach to tabu. Nazwanie Groda pasożytem jest obelgą. \
			Mówią o sobie „my”, nie mają płci i zwykle są spokojni i uprzejmi.",
	)

/datum/species/grod/create_pref_unique_perks()
	return list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "crown",
			SPECIES_PERK_NAME = "Korona",
			SPECIES_PERK_DESC = "W każdej chwili możesz opuścić ciało jako pająk-korona i przejąć ciało bez mózgu. \
				Pająk jest jednak kruchy i wolny, a śmierć w tej postaci jest ostateczna. Inni mogą cię podnieść i nosić na głowie.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "hand-paper",
			SPECIES_PERK_NAME = "Cztery ręce",
			SPECIES_PERK_DESC = "Masz drugą parę rąk na odnóżach: trzymają i używają przedmiotów jak zwykłe dłonie, a w HUD-zie mają własne sloty nad rękami.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Odporna skorupa",
			SPECIES_PERK_DESC = "Znosisz niskie ciśnienie, nie ślizgasz się na wodzie, lepiej znosisz zimno i toksyny.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Miękkie ciało",
			SPECIES_PERK_DESC = "Obrażenia fizyczne i oparzenia ranią cię mocniej, gorąco jeszcze bardziej. Szybciej się męczysz.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "tshirt",
			SPECIES_PERK_NAME = "Własna moda",
			SPECIES_PERK_DESC = "Nosisz tylko kamizelki, cylindry, buty i rękawice uszyte dla Grodów. Stroje wierzchnie, skafandry i pancerze na ciebie nie wejdą.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "seedling",
			SPECIES_PERK_NAME = "Wegetarianin",
			SPECIES_PERK_DESC = "Mięso i surowizna ci szkodzą, środki chwastobójcze trują. Nie da się cię sklonować.",
		),
	)

// Okno postaci: korona, wzory (z kolorem) i ogon

/datum/preference/choiced/species_feature/grod_crown
	db_key = "feature_grod_crown"
	feature_key = "grod_crown"
	relevant_mutant_bodypart = "grod_crown"
	main_feature_name = "Korona"
	should_generate_icons = TRUE
	accessory_list = "grod_crowns_list"
	icon_key = "grod_crown"
	icon_base_file = GROD_ICON_BODY
	icon_base_state = "grod_head"
	icon_color = "#3fae3f"

/datum/preference/choiced/species_feature/grod_crown/get_display_names()
	return grod_display_names(get_choices())

/datum/preference/choiced/species_feature/grod_marks
	db_key = "feature_grod_marks"
	feature_key = "grod_marks"
	relevant_mutant_bodypart = "grod_marks"
	main_feature_name = "Wzory"
	should_generate_icons = TRUE
	accessory_list = "grod_marks_list"
	icon_key = "grod_marks"
	icon_base_file = GROD_ICON_BODY
	icon_base_state = "grod_chest"
	icon_color = "#3fae3f"
	icon_dir = NORTH
	icon_crop_head = FALSE

/datum/preference/choiced/species_feature/grod_marks/get_display_names()
	return grod_display_names(get_choices())

/datum/preference/choiced/species_feature/grod_marks/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "feature_grod_marks_color"
	return data

/datum/preference/color/grod_marks_color
	db_key = "feature_grod_marks_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	feature_key = "grod_marks_color"
	relevant_mutant_bodypart = "grod_marks"

/datum/preference/color/grod_marks_color/read_value(datum/preferences/prefs)
	return ..() || "e8e04a"

/datum/preference/choiced/species_feature/grod_tail
	db_key = "feature_grod_tail"
	feature_key = "grod_tail"
	relevant_mutant_bodypart = "grod_tail"
	main_feature_name = "Ogon"
	should_generate_icons = TRUE
	accessory_list = "grod_tails_list"
	icon_key = "grod_tail"
	icon_base_file = GROD_ICON_BODY
	icon_base_state = "grod_chest"
	icon_color = "#3fae3f"
	icon_dir = EAST
	icon_crop_head = FALSE

/datum/preference/choiced/species_feature/grod_tail/get_display_names()
	return grod_display_names(get_choices())

/proc/grod_display_names(list/choices)
	var/list/names = list()
	for(var/value in choices)
		names[value] = GLOB.grod_accessory_names[value] || value
	return names
