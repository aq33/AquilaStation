/// Pretty simple mob which creates areas of rust and has a rust-creating projectile spell
/mob/living/simple_animal/hostile/heretic_summon/rust_walker
	name = "\improper Rust Walker"
	real_name = "Rusty"
	desc = "Zgrzytający, szczękający konstrukt, który każdym opancerzonym krokiem wysysa życie z otoczenia."
	icon_state = "rust_walker_s"
	icon_living = "rust_walker_s"
	maxHealth = 100
	health = 100
	melee_damage = 17
	sight = SEE_TURFS
	speed = 1
	mob_biotypes = list(MOB_ROBOTIC)

/mob/living/simple_animal/hostile/heretic_summon/rust_walker/Initialize(mapload)
	. = ..()
	var/static/list/grantable_spells = list(
		/datum/action/cooldown/spell/aoe/rust_conversion,
		/datum/action/cooldown/spell/basic_projectile/rust_wave/short,
	)
	grant_actions_by_list(grantable_spells)

/mob/living/simple_animal/hostile/heretic_summon/rust_walker/setDir(newdir)
	. = ..()
	update_dir_icon()

/mob/living/simple_animal/hostile/heretic_summon/rust_walker/do_rust_heretic_act(atom/target)
	target.rust_heretic_act(RUST_RESISTANCE_TITANIUM)

/// Sprite zależny od kierunku (północ/południe)
/mob/living/simple_animal/hostile/heretic_summon/rust_walker/proc/update_dir_icon()
	if(stat == DEAD) // We usually delete on death but just in case
		return
	if(dir & NORTH)
		icon_state = "rust_walker_n"
	else if(dir & SOUTH)
		icon_state = "rust_walker_s"
	icon_living = icon_state

/mob/living/simple_animal/hostile/heretic_summon/rust_walker/Life(seconds, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	var/turf/our_turf = get_turf(src)
	if(HAS_TRAIT(our_turf, TRAIT_RUSTY))
		adjustBruteLoss(-3 * seconds)
