// AQUILA - animacje ataku i ataki alternatywne z tgstation/tgstation#88418 (z poprawką #90187).
// Przedmioty ostre zamachują się łukiem, szpiczaste pchają do przodu, tępe uderzają jak dotąd. To tylko efekt.
// Rodzaj animacji wynika z rany, jaką zadaje przedmiot (get_wound_kind: kłuta = pchnięcie) i z ostrości
// (is_sharp: cięcie), bo nie mamy podziału ostrości tg na SHARP_EDGED i SHARP_POINTY.
// Noże, miecze i podobne mają pchnięcie na prawym przycisku (w trybie intencji: na intencji rozbrajania):
// zadaje rany kłute zamiast ciętych, zwykle za mniejsze obrażenia. Kąty sprite'ów są w icon_angles.dm.

/obj/item
	/// Kąt sprite'a zgodnie z ruchem wskazówek zegara od sprite'a skierowanego na wschód (animacje cięcia i pchnięcia)
	var/icon_angle = 0
	/// Wymuszony rodzaj animacji ataku (ATTACK_ANIMATION_*), null: z rodzaju rany i ostrości
	var/attack_animation
	/// Pchnięcie na prawym przycisku (ALT_ATTACK_STAB_*), null: brak
	var/alt_attack
	/// O ile zmienia się siła przy pchnięciu
	var/alt_attack_force_mod = 0

GLOBAL_LIST_INIT(alt_attack_verbs, list(
	ALT_ATTACK_STAB_KNIFE = list("dźga", "przebija", "kłuje"),
	ALT_ATTACK_STAB_SWORD = list("dźga", "przebija", "nadziewa"),
))

/obj/item/Initialize(mapload)
	. = ..()
	if(alt_attack)
		AddComponent(/datum/component/alternative_sharpness, GLOB.alt_attack_verbs[alt_attack], alt_attack_force_mod)

/// Rodzaj animacji ataku tym przedmiotem
/obj/item/proc/get_attack_animation()
	if(attack_animation)
		return attack_animation
	if(get_wound_kind() == WOUND_PIERCE)
		return ATTACK_ANIMATION_PIERCE
	if(is_sharp())
		return ATTACK_ANIMATION_SLASH
	return ATTACK_ANIMATION_BLUNT

/// Czy pchnięcie jest teraz możliwe (np. miecz energetyczny musi być włączony)
/obj/item/proc/alt_attack_ready()
	return TRUE

/obj/item/melee/transforming/alt_attack_ready()
	return active

/obj/item/pen/edagger/alt_attack_ready()
	return on

/obj/item/switchblade/alt_attack_ready()
	return extended

// Pełne nadpisanie bez ..(): nowa animacja przedmiotu zamiast starego „podlotu” ikony (LEGACY_OVERRIDES.md)
/atom/movable/do_item_attack_animation(atom/A, visual_effect_icon, obj/item/used_item)
	if(visual_effect_icon)
		var/image/effect_image = image('icons/effects/effects.dmi', A, visual_effect_icon, A.layer + 0.1)
		effect_image.plane = GAME_PLANE
		effect_image.transform *= 0.4
		effect_image.appearance_flags = APPEARANCE_UI | KEEP_APART
		flick_overlay(effect_image, GLOB.clients, 1 SECONDS)
		animate(effect_image, alpha = 175, transform = matrix() * 0.75, time = 0.3 SECONDS)
		animate(time = 0.1 SECONDS)
		animate(alpha = 0, time = 0.3 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)
		return

	if(isnull(used_item))
		return

	var/image/attack = image(icon = used_item, loc = A, layer = A.layer + 0.1)
	attack.plane = GAME_PLANE
	// Obrazek siedzi na celu i ma jego przesunięcie, więc liczymy od atakującego (jak tg: duże moby z base_pixel_x)
	attack.pixel_w = base_pixel_x - A.base_pixel_x
	attack.pixel_z = base_pixel_y - A.base_pixel_y
	attack.transform *= 0.5
	// KEEP_APART: człowiek ma KEEP_TOGETHER, a wtedy dołączony obrazek dziedziczy jego obrót mimo RESET_TRANSFORM.
	// Przy leżącym celu przedmiot lądował obrócony i z innej strony (tak samo vis_contents z tg).
	attack.appearance_flags = APPEARANCE_UI | KEEP_APART
	flick_overlay(attack, GLOB.clients, 1 SECONDS)

	var/matrix/copy_transform = matrix()
	var/x_sign = 0
	var/y_sign = 0
	var/direction = get_dir(src, A)
	if(direction & NORTH)
		y_sign = -1
	else if(direction & SOUTH)
		y_sign = 1
	if(direction & EAST)
		x_sign = -1
	else if(direction & WEST)
		x_sign = 1

	// Atak na siebie albo na coś na tym samym polu
	if(!direction)
		y_sign = 1
		x_sign = 0.25 * (prob(50) ? 1 : -1)
		direction = SOUTH

	switch(used_item.get_attack_animation())
		if(ATTACK_ANIMATION_PIERCE)
			var/attack_angle = dir2angle(direction) + rand(-7, 7)
			// icon_angle 0 to sprite skierowany na wschód, stąd -90
			var/anim_angle = attack_angle - 90 - used_item.icon_angle
			var/angle_mult = 1
			if(x_sign && y_sign)
				angle_mult = 1.4
			attack.pixel_x = 22 * x_sign * angle_mult
			attack.pixel_y = 18 * y_sign * angle_mult
			attack.transform = attack.transform.Turn(anim_angle)
			copy_transform = copy_transform.Turn(anim_angle)
			animate(attack, pixel_x = (22 * x_sign - 12 * sin(attack_angle)) * angle_mult, pixel_y = (18 * y_sign - 8 * cos(attack_angle)) * angle_mult, time = 0.1 SECONDS, easing = CUBIC_EASING|EASE_IN)
			animate(alpha = 175, transform = copy_transform.Scale(0.75), pixel_x = (22 * x_sign + 26 * sin(attack_angle)) * angle_mult, pixel_y = (18 * y_sign + 22 * cos(attack_angle)) * angle_mult, time = 0.3 SECONDS, easing = CUBIC_EASING|EASE_OUT)
			animate(alpha = 0, pixel_x = -3 * -(x_sign + sin(attack_angle)), pixel_y = -2 * -(y_sign + cos(attack_angle)), time = 0.1 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

		if(ATTACK_ANIMATION_SLASH)
			attack.pixel_x = 18 * x_sign
			attack.pixel_y = 14 * y_sign
			var/x_rot_sign = 0
			var/y_rot_sign = 0
			var/attack_dir = (prob(50) ? 1 : -1)
			var/anim_angle = dir2angle(direction) - 90 - used_item.icon_angle

			if(x_sign)
				y_rot_sign = attack_dir
			if(y_sign)
				x_rot_sign = attack_dir

			// Animacje są odbite, więc odbijamy też kierunek zamachu
			if(x_sign > 0 || y_sign < 0)
				attack_dir *= -1

			// Zamach po skosie
			var/anim_dir = attack_dir
			if(x_sign && y_sign)
				if(attack_dir < 0)
					x_rot_sign = -x_sign * 1.4
					y_rot_sign = 0
				else
					x_rot_sign = 0
					y_rot_sign = -y_sign * 1.4
				if((x_sign < 0 && y_sign > 0) || (x_sign > 0 && y_sign < 0))
					anim_dir *= -1

			attack.pixel_x += 10 * x_rot_sign
			attack.pixel_y += 8 * y_rot_sign
			attack.transform = attack.transform.Turn(anim_angle - 45 * anim_dir)
			copy_transform = copy_transform.Scale(0.75)
			animate(attack, alpha = 175, time = 0.3 SECONDS, flags = ANIMATION_PARALLEL)
			animate(time = 0.1 SECONDS)
			animate(alpha = 0, time = 0.1 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

			animate(attack, transform = copy_transform.Turn(anim_angle + 45 * anim_dir), time = 0.3 SECONDS, flags = ANIMATION_PARALLEL)

			var/x_return = 10 * -x_rot_sign
			var/y_return = 8 * -y_rot_sign
			if(!x_rot_sign)
				x_return = 18 * x_sign
			if(!y_rot_sign)
				y_return = 14 * y_sign

			var/angle_mult = 1
			if(x_sign && y_sign)
				angle_mult = 1.4
				if(attack_dir > 0)
					x_return = 8 * x_sign
					y_return = 14 * y_sign
				else
					x_return = 18 * x_sign
					y_return = 6 * y_sign

			animate(attack, pixel_x = 4 * x_sign * angle_mult, time = 0.2 SECONDS, easing = CIRCULAR_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
			animate(pixel_x = x_return, time = 0.2 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

			animate(attack, pixel_y = 3 * y_sign * angle_mult, time = 0.2 SECONDS, easing = CIRCULAR_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
			animate(pixel_y = y_return, time = 0.2 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

		else
			attack.pixel_x = 14 * x_sign
			attack.pixel_y = 12 * y_sign
			animate(attack, alpha = 175, transform = copy_transform.Scale(0.75), pixel_x = 4 * x_sign, pixel_y = 3 * y_sign, time = 0.2 SECONDS)
			animate(time = 0.1 SECONDS)
			animate(alpha = 0, time = 0.1 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

/// Pchnięcie na prawym przycisku: na czas jednego ataku przedmiot zadaje rany kłute, ma inne czasowniki i siłę
/datum/component/alternative_sharpness
	/// Czasowniki ataku przy pchnięciu
	var/list/alt_verbs
	/// O ile zmienia się siła przy pchnięciu
	var/force_mod = 0
	/// Trwa pchnięcie
	var/alt_attacking = FALSE
	// Wartości sprzed pchnięcia
	var/list/base_verbs
	var/base_wound_kind
	var/base_animation
	/// Siła w trakcie pchnięcia; inna przy przywracaniu znaczy, że coś (np. wyłączenie miecza) ją ustawiło
	var/alt_force

/datum/component/alternative_sharpness/Initialize(list/alt_verbs, force_mod = 0)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.alt_verbs = alt_verbs
	src.force_mod = force_mod

/datum/component/alternative_sharpness/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK_SECONDARY, PROC_REF(on_secondary_attack))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/alternative_sharpness/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_PRE_ATTACK_SECONDARY, COMSIG_PARENT_EXAMINE))

/datum/component/alternative_sharpness/proc/on_examine(obj/item/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "<span class='notice'>Możesz nim dźgnąć [user.secondary_click_text()]: pchnięcie zadaje rany kłute zamiast ciętych.</span>"

/datum/component/alternative_sharpness/proc/on_secondary_attack(obj/item/source, atom/target, mob/user, params)
	SIGNAL_HANDLER
	if(alt_attacking || !source.alt_attack_ready())
		return
	alt_attacking = TRUE
	source.force += force_mod
	alt_force = source.force
	base_verbs = source.attack_verb
	base_wound_kind = source.wound_kind
	base_animation = source.attack_animation
	source.attack_verb = alt_verbs
	source.wound_kind = WOUND_PIERCE
	source.attack_animation = ATTACK_ANIMATION_PIERCE
	// Jak w tg: atak kończy się w tym samym ticku, więc przywracamy wartości w następnym
	addtimer(CALLBACK(src, PROC_REF(disable_alt_attack)), 1)

/datum/component/alternative_sharpness/proc/disable_alt_attack()
	if(!alt_attacking)
		return
	var/obj/item/weapon = parent
	alt_attacking = FALSE
	if(weapon.force == alt_force)
		weapon.force -= force_mod
	weapon.attack_verb = base_verbs
	weapon.wound_kind = base_wound_kind
	weapon.attack_animation = base_animation

// Bronie z pchnięciem (wartości siły z tg)
/obj/item/kitchen/knife
	alt_attack = ALT_ATTACK_STAB_KNIFE
/obj/item/kitchen/knife/butcher
	alt_attack = null
/obj/item/kitchen/knife/hunting
	alt_attack = null
/obj/item/kitchen/knife/combat
	alt_attack_force_mod = -5
/obj/item/kitchen/knife/carrotshiv
	alt_attack_force_mod = -3
/obj/item/switchblade
	alt_attack = ALT_ATTACK_STAB_KNIFE
	alt_attack_force_mod = -5
/obj/item/pen/edagger
	alt_attack = ALT_ATTACK_STAB_KNIFE
	alt_attack_force_mod = -5
/obj/item/scalpel
	alt_attack = ALT_ATTACK_STAB_KNIFE
/obj/item/nullrod/tribal_knife
	alt_attack = ALT_ATTACK_STAB_KNIFE
	alt_attack_force_mod = -3
/obj/item/melee/transforming/energy/sword
	alt_attack = ALT_ATTACK_STAB_SWORD
	alt_attack_force_mod = -10
/obj/item/melee/transforming/energy/blade
	alt_attack = ALT_ATTACK_STAB_SWORD
	alt_attack_force_mod = -10
/obj/item/melee/synthetic_arm_blade
	alt_attack = ALT_ATTACK_STAB_SWORD
	alt_attack_force_mod = -5
/obj/item/melee/arm_blade
	alt_attack = ALT_ATTACK_STAB_SWORD
	alt_attack_force_mod = -5
/obj/item/claymore
	alt_attack = ALT_ATTACK_STAB_SWORD
	alt_attack_force_mod = -15
/obj/item/claymore/weak
	alt_attack_force_mod = -9
/obj/item/claymore/weak/ceremonial
	alt_attack_force_mod = -5
/obj/item/katana
	alt_attack = ALT_ATTACK_STAB_SWORD
	alt_attack_force_mod = -15
/obj/item/toy/katana
	alt_attack = ALT_ATTACK_STAB_SWORD
/obj/item/melee/cultblade
	alt_attack = ALT_ATTACK_STAB_SWORD
	alt_attack_force_mod = -5
/obj/item/melee/rune_carver
	alt_attack = ALT_ATTACK_STAB_KNIFE
/obj/item/nullrod/claymore
	alt_attack = ALT_ATTACK_STAB_SWORD
	alt_attack_force_mod = -3
/obj/item/nullrod/scythe/vibro
	alt_attack = ALT_ATTACK_STAB_SWORD
	alt_attack_force_mod = -3
/obj/item/melee/ghost_sword
	alt_attack = ALT_ATTACK_STAB_SWORD

// Podtypy, które nie są ostrzami do pchnięcia (kij, piły, banan)
/obj/item/nullrod/claymore/bostaff
	alt_attack = null
/obj/item/nullrod/claymore/chainsaw_sword
	alt_attack = null
/obj/item/melee/transforming/energy/sword/bananium
	alt_attack = null
/obj/item/melee/transforming/energy/sword/esaw
	alt_attack = null
/obj/item/melee/transforming/energy/sword/cyborg/saw
	alt_attack = null
