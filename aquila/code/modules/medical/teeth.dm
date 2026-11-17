// AQUILA - zęby (AquilaMed 5, etap 7). Port z /vg/station13 (code/game/objects/items/stacks/teeth.dm,
// code/modules/surgery/tooth.dm, knock_out_teeth w human_defense.dm), sprite'y zębów z /vg/ (CC BY-SA 3.0).
// - Organiczna głowa ma 32 zęby. Tępy cios przedmiotem w usta (bez pancerza na głowie) może wybić 1-3 zęby jak na /vg/,
//   u nas także pięść, rzadziej. Zęby lecą na podłogę jako stos.
// - Różnice od /vg/: zamiast kroków nastawiania szczęki są dwie operacje (wyrwanie zęba i wstawienie zęba), jest
//   seplenienie przy braku zębów, protezy i złote zęby z protolathe, a implant pigułki wymaga choć jednego zęba.
//   Bez naszyjnika z zębów i bez zębów zwierząt.

#define AQ_TEETH_MAX 32
/// Missing teeth from which speech starts to lisp
#define AQ_TEETH_LISP_FROM 8

/obj/item/bodypart/head
	/// Teeth left in this head (only organic heads have teeth)
	var/aq_teeth = AQ_TEETH_MAX

/obj/item/stack/teeth
	name = "zęby"
	singular_name = "ząb"
	desc = "Wybite albo wyrwane zęby. Dentysta może je wsadzić z powrotem."
	icon = 'aquila/icons/obj/medical/teeth.dmi'
	icon_state = "tooth"
	w_class = WEIGHT_CLASS_TINY
	max_amount = 50
	throw_speed = 4
	throw_range = 10
	novariants = TRUE

/obj/item/stack/teeth/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 8)

/obj/item/stack/teeth/prosthetic
	name = "sztuczne zęby"
	singular_name = "sztuczny ząb"
	desc = "Porcelanowe protezy zębów. Dentysta wstawia je jak prawdziwe."
	icon_state = "tooth-prosthetic"

/obj/item/stack/teeth/gold
	name = "złote zęby"
	singular_name = "złoty ząb"
	desc = "Złote protezy zębów. Błyszczą przy każdym uśmiechu."
	icon_state = "tooth-gold"

/// Knocks teeth out of the mouth onto the floor; returns how many fell out
/mob/living/carbon/human/proc/aq_knock_out_teeth(mob/living/attacker, amount = rand(1, 3))
	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	if(!istype(head) || !IS_ORGANIC_LIMB(head) || head.aq_teeth <= 0)
		return 0
	amount = min(amount, head.aq_teeth)
	head.aq_teeth -= amount
	var/obj/item/stack/teeth/teeth = new(drop_location(), amount)
	var/turf/target = get_step(get_turf(src), attacker ? get_dir(attacker, src) : dir)
	if(target)
		teeth.throw_at(target, 2, 2)
	if(attacker)
		var/what = amount == 1 ? "ząb" : (amount > 2 ? "kilka zębów" : "zęby")
		visible_message("<span class='danger'>[attacker] wybija [src] [what]!</span>", "<span class='userdanger'>[attacker] wybija ci [what]!</span>")
	return amount

/// A blunt blow aimed at the mouth can knock teeth out (/vg/: no head armor, chance force * size, at most 40%)
/mob/living/carbon/human/proc/aq_try_knock_teeth(mob/living/user, force, size, sharp)
	if(!user || user.zone_selected != BODY_ZONE_PRECISE_MOUTH || sharp || force <= 0)
		return FALSE
	if(force < 8 && size < WEIGHT_CLASS_SMALL)
		return FALSE
	if(getarmor(BODY_ZONE_HEAD, MELEE) > 0)
		return FALSE
	if(!prob(min(force * size, 40)))
		return FALSE
	return aq_knock_out_teeth(user)

/datum/species/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/H)
	. = ..()
	if(. && I && affecting?.body_zone == BODY_ZONE_HEAD && I.damtype == BRUTE)
		H.aq_try_knock_teeth(user, I.force, I.w_class, I.is_sharp())

/// Fists knock teeth out more rarely than weapons
/datum/species/spec_unarmedattacked(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	if(user && target && user.zone_selected == BODY_ZONE_PRECISE_MOUTH)
		target.aq_try_knock_teeth(user, user.dna.species.punchdamage, 1, FALSE)

/// Missing teeth make the speech lisp
/mob/living/carbon/human/treat_message(message)
	. = ..()
	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	if(!istype(head) || !IS_ORGANIC_LIMB(head) || !. || copytext(., 1, 2) == "*")
		return
	var/missing = AQ_TEETH_MAX - head.aq_teeth
	if(missing < AQ_TEETH_LISP_FROM)
		return
	. = aq_lisp(., head.aq_teeth ? min(90, (missing - 4) * 4) : 100)

/// Polish lisping: sibilants turn soft, word by word with the given chance
/proc/aq_lisp(message, chance)
	var/static/list/sounds = list("sz" = "ś", "Sz" = "Ś", "SZ" = "Ś", "cz" = "ć", "Cz" = "Ć", "CZ" = "Ć", "ż" = "ź", "Ż" = "Ź", "s" = "ś", "S" = "Ś", "z" = "ź", "Z" = "Ź", "c" = "ć", "C" = "Ć")
	var/list/words = splittext(message, " ")
	for(var/i in 1 to length(words))
		if(!prob(chance))
			continue
		var/word = words[i]
		for(var/sound in sounds)
			word = replacetextEx(word, sound, sounds[sound])
		words[i] = word
	return jointext(words, " ")

/mob/living/carbon/human/get_wound_scan_lines()
	. = ..()
	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	if(istype(head) && IS_ORGANIC_LIMB(head) && head.aq_teeth < AQ_TEETH_MAX)
		. += "<span class='notice'>Zęby: [head.aq_teeth] z [AQ_TEETH_MAX].</span>"

/mob/living/carbon/human/examine(mob/user)
	. = ..()
	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	if(!istype(head) || !IS_ORGANIC_LIMB(head) || head.aq_teeth >= AQ_TEETH_MAX || is_mouth_covered())
		return
	if(!head.aq_teeth)
		. += "<span class='warning'>Nie ma ani jednego zęba.</span>"
	else if(user && get_dist(user, src) <= 1)
		. += "<span class='warning'>Brakuje [AQ_TEETH_MAX - head.aq_teeth] zębów.</span>"
	else
		. += "<span class='warning'>Brakuje kilku zębów.</span>"

/mob/living/carbon/fully_heal(admin_revive = FALSE)
	. = ..()
	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	if(istype(head))
		head.aq_teeth = AQ_TEETH_MAX

/// A pill implant needs a tooth to sit in
/datum/surgery_operation/limb/add_dental_implant/state_check(obj/item/bodypart/limb)
	var/obj/item/bodypart/head/head = limb
	return ..() && istype(head) && head.aq_teeth > 0

// --- Operacje ---

/datum/surgery_operation/limb/aq_pull_tooth
	name = "wyrwanie zęba"
	catalog_sections = list(SURGERY_SECTION_FACE)
	desc = "Wyrywa pacjentowi jeden ząb."
	operation_flags = OPERATION_SELF_OPERABLE
	self_operable_zones = list(BODY_ZONE_PRECISE_MOUTH)
	implements = list(TOOL_HEMOSTAT = 1, TOOL_WIRECUTTER = 2, /obj/item/assembly/mousetrap = 10)
	time = 5 SECONDS
	required_bodytype = BODYTYPE_ORGANIC
	preop_sound = 'sound/surgery/hemostat1.ogg'

/datum/surgery_operation/limb/aq_pull_tooth/all_required_strings()
	return list("operacja na: [strefa_pl(BODY_ZONE_PRECISE_MOUTH)]", "pacjent musi mieć zęby") + ..()

/datum/surgery_operation/limb/aq_pull_tooth/get_default_radial_image()
	return image(icon = 'aquila/icons/obj/medical/teeth.dmi', icon_state = "tooth")

/datum/surgery_operation/limb/aq_pull_tooth/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	return operated_zone == BODY_ZONE_PRECISE_MOUTH

/datum/surgery_operation/limb/aq_pull_tooth/state_check(obj/item/bodypart/limb)
	var/obj/item/bodypart/head/head = limb
	return istype(head) && head.aq_teeth > 0

/datum/surgery_operation/limb/aq_pull_tooth/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("Zaczynasz wyrywać ząb [limb.owner]..."), span_notice("[surgeon] zaczyna wyrywać ząb [limb.owner]."), span_notice("[surgeon] grzebie w ustach [limb.owner]."))
	display_pain(limb.owner, "Ząb trzeszczy i promieniuje bólem na całą szczękę!")

/datum/surgery_operation/limb/aq_pull_tooth/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/bodypart/head/head = limb
	if(!istype(head) || head.aq_teeth <= 0)
		return
	head.aq_teeth--
	new /obj/item/stack/teeth(get_turf(limb.owner || limb), 1)
	display_results(surgeon, limb.owner, span_notice("Wyrywasz ząb [limb.owner]."), span_notice("[surgeon] wyrywa ząb [limb.owner]."), span_notice("[surgeon] wyrywa coś z ust [limb.owner]."))

/datum/surgery_operation/limb/aq_pull_tooth/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	limb.receive_damage(5)
	display_results(surgeon, limb.owner, span_warning("Ręka ci się ześlizguje i rozdzierasz dziąsło [limb.owner]!"), span_warning("[surgeon] rozdziera dziąsło [limb.owner]!"), span_warning("[surgeon] partaczy!"))

/datum/surgery_operation/limb/aq_insert_tooth
	name = "wstawienie zęba"
	catalog_sections = list(SURGERY_SECTION_FACE)
	desc = "Wszczepia ząb (własny, sztuczny albo złoty) w puste miejsce w szczęce. Dziąsło trzeba najpierw naciąć."
	implements = list(/obj/item/stack/teeth = 1)
	consumes_stack_tool = FALSE // on_success uses the planted tooth itself
	time = 6 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED
	required_bodytype = BODYTYPE_ORGANIC
	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_operation/limb/aq_insert_tooth/all_required_strings()
	return list("operacja na: [strefa_pl(BODY_ZONE_PRECISE_MOUTH)]", "pacjentowi musi brakować zęba") + ..()

/datum/surgery_operation/limb/aq_insert_tooth/get_default_radial_image()
	return image(icon = 'aquila/icons/obj/medical/teeth.dmi', icon_state = "tooth-prosthetic")

/datum/surgery_operation/limb/aq_insert_tooth/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	return operated_zone == BODY_ZONE_PRECISE_MOUTH

/datum/surgery_operation/limb/aq_insert_tooth/state_check(obj/item/bodypart/limb)
	var/obj/item/bodypart/head/head = limb
	return istype(head) && head.aq_teeth < AQ_TEETH_MAX

/datum/surgery_operation/limb/aq_insert_tooth/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("Zaczynasz wszczepiać ząb w szczękę [limb.owner]..."), span_notice("[surgeon] zaczyna wszczepiać ząb w szczękę [limb.owner]."), span_notice("[surgeon] grzebie w ustach [limb.owner]."))

/datum/surgery_operation/limb/aq_insert_tooth/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/stack/teeth/tool, list/operation_args)
	var/obj/item/bodypart/head/head = limb
	if(!istype(head) || head.aq_teeth >= AQ_TEETH_MAX || !istype(tool) || !tool.use(1))
		return
	head.aq_teeth++
	display_results(surgeon, limb.owner, span_notice("Wszczepiasz ząb [limb.owner]."), span_notice("[surgeon] wszczepia ząb [limb.owner]."), span_notice("[surgeon] kończy grzebać w ustach [limb.owner]."))

/datum/surgery_operation/limb/aq_insert_tooth/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	limb.receive_damage(5)
	display_results(surgeon, limb.owner, span_warning("Ręka ci się ześlizguje i kaleczysz dziąsło [limb.owner]!"), span_warning("[surgeon] kaleczy dziąsło [limb.owner]!"), span_warning("[surgeon] partaczy!"))

/datum/design/aq_prosthetic_teeth
	name = "Sztuczne zęby (5)"
	desc = "Porcelanowe protezy zębów do wstawienia operacją."
	id = "aq_prosthetic_teeth"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/glass = 250, /datum/material/iron = 100)
	build_path = /obj/item/stack/teeth/prosthetic/five
	category = list("Medical Designs", "Medical")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aq_gold_teeth
	name = "Złote zęby (5)"
	desc = "Złote protezy zębów do wstawienia operacją."
	id = "aq_gold_teeth"
	build_type = PROTOLATHE
	materials = list(/datum/material/gold = 500)
	build_path = /obj/item/stack/teeth/gold/five
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/obj/item/stack/teeth/prosthetic/five
	amount = 5

/obj/item/stack/teeth/gold/five
	amount = 5

#undef AQ_TEETH_LISP_FROM
