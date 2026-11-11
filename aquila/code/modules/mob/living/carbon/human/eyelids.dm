// AQUILA - mruganie (uproszczony port z tgstation/tgstation, /obj/item/organ/eyes/proc/get_eyelid_overlays)
// Różnice względem tg:
// - u nas oczy to jedna nakładka „eyes” z human_face.dmi, więc jest jedna powieka na oba oczy (zawsze zsynchronizowane)
// - nieprzytomny i martwy ma zamknięte oczy: nakładka oczu dostaje kolor powieki (jak w tg)
// - bez powiek: mechaniczne oczy, mechaniczna głowa, rasy bez koloru skóry na głowie

#define BLINK_BASE_DELAY (5 SECONDS)
#define BLINK_RAND_DELAY (1 SECONDS)
#define BLINK_DURATION (0.15 SECONDS)
#define BLINK_LOOPS 5

/mob/living/carbon/human
	/// Niewidoczny obiekt w vis_contents, z którego nakładka powieki bierze obraz (render_target)
	var/obj/effect/abstract/eyelid_effect/eyelid

/mob/living/carbon/human/Destroy()
	if(eyelid)
		vis_contents -= eyelid
		QDEL_NULL(eyelid)
	return ..()

/mob/living/carbon/human/set_stat(new_stat)
	var/old_stat = stat
	. = ..()
	if(old_stat != stat && ((old_stat >= UNCONSCIOUS) != (stat >= UNCONSCIOUS)))
		update_body()

/// Kolor powieki: kolor skóry głowy, odrobinę ciemniejszy. null = ta głowa nie ma powiek.
/mob/living/carbon/human/proc/get_eyelid_color(obj/item/bodypart/head/head, obj/item/organ/eyes/eyes)
	if(!head || !eyes || !IS_ORGANIC_LIMB(head) || eyes.status == ORGAN_ROBOTIC || !head.draw_color)
		return null
	// draw_color bywa z „#” (species_color z fixed_mut_color, np. miedziany golem) albo bez (skintone2hex, mcolor)
	var/skin_color = head.draw_color
	if(copytext(skin_color, 1, 2) != "#")
		skin_color = "#[skin_color]"
	var/list/hsl = rgb2num(skin_color, COLORSPACE_HSL)
	return rgb(hsl[1], hsl[2] * 0.85, hsl[3] * 0.85, space = COLORSPACE_HSL)

/// Wołane z handle_body() zaraz po nakładce oczu. Zwraca nakładki do dorzucenia.
/mob/living/carbon/human/proc/get_eyelid_overlays(mutable_appearance/eye_overlay, obj/item/organ/eyes/eyes, obj/item/bodypart/head/head)
	. = list()
	var/eyelid_color = get_eyelid_color(head, eyes)
	if(!eyelid_color)
		return
	// Nieprzytomny albo martwy: oczy zamknięte
	if(stat >= UNCONSCIOUS)
		eye_overlay.color = eyelid_color
		return
	if(!eyelid)
		eyelid = new(null)
		eyelid.render_target = "*[REF(src)]_eyelid"
		vis_contents += eyelid
		eyelid.start_blinking()
	eyelid.icon_state = eyes.eye_icon_state
	eyelid.color = eyelid_color
	var/mutable_appearance/eyelid_overlay = mutable_appearance(layer = -BODY_LAYER)
	eyelid_overlay.render_source = eyelid.render_target
	eyelid_overlay.pixel_x = eye_overlay.pixel_x
	eyelid_overlay.pixel_y = eye_overlay.pixel_y
	. += eyelid_overlay

/obj/effect/abstract/eyelid_effect
	name = "powieka"
	icon = 'icons/mob/human_face.dmi'
	icon_state = "eyes"
	alpha = 0
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE | VIS_INHERIT_ID

/// Pętla mrugnięć co ~5 s (powieka zasłania oczy na 0.15 s)
/obj/effect/abstract/eyelid_effect/proc/start_blinking()
	animate(src, alpha = 0, time = 0, loop = -1)
	for(var/i in 1 to BLINK_LOOPS)
		animate(time = rand(BLINK_BASE_DELAY - BLINK_RAND_DELAY, BLINK_BASE_DELAY + BLINK_RAND_DELAY))
		animate(alpha = 255, time = 0)
		animate(time = BLINK_DURATION)
		animate(alpha = 0, time = 0)

#undef BLINK_BASE_DELAY
#undef BLINK_RAND_DELAY
#undef BLINK_DURATION
#undef BLINK_LOOPS
