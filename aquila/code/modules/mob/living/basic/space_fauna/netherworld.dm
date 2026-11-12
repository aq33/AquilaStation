// AQUILA: port of tgstation code/modules/mob/living/basic/space_fauna/netherworld/ (creature.dm, migo.dm, blankbody.dm; tg 926bf40c5a)
// in place of our simple animal netherworld.dm. Polish names and lines, health and damage of our simple animals.
// Changes against tg:
// - the creature (our /hostile/netherworld) keeps our 80 health and 35 damage; its health scaling adds only +10 damage and the
//   speed when hurt (tg's +15-30 on top of 20-30 damage would nearly double our values);
// - the blank body keeps 10 damage with tg's scaling (+8-14 when hurt), the mi-go keeps 80 health and 35 damage with tg's dodging;
// - no swabbing (no cytology), no Miss Tiggles, hatchling or hatsune mi-go; the mi-go keeps our sound list (our paths);
// - the Netherworld link spawner (spawner/nether) moved here with the mobs, unchanged.
/mob/living/basic/creature
	name = "istota"
	desc = "Niszczące umysł coś-innego z zaświatów."
	icon_state = "otherthing"
	icon_living = "otherthing"
	icon_dead = "otherthing-dead"
	health = 80
	maxHealth = 80
	obj_damage = 100
	melee_damage = 35
	attack_verb_continuous = "tnie"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	melee_attack_cooldown = 1 SECONDS
	faction = list("nether")
	speak_emote = list("krzyczy")
	gold_core_spawnable = HOSTILE_SPAWN
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	discovery_points = 3000
	ai_controller = /datum/ai_controller/basic_controller/simple_hostile_obstacles
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	/// Does it get stronger and faster when hurt
	var/health_scaling = TRUE

/mob/living/basic/creature/Initialize(mapload)
	. = ..()
	if(health_scaling)
		AddComponent(\
			/datum/component/health_scaling_effects,\
			min_health_attack_modifier_lower = 10,\
			min_health_attack_modifier_upper = 10,\
			min_health_slowdown = -1.5,\
		)
	var/datum/action/cooldown/spell/jaunt/creature_teleport/teleport = new(src)
	teleport.Grant(src)

/// Jaunt spell used by creature. Can only jaunt or unjaunt if nothing can see you.
/datum/action/cooldown/spell/jaunt/creature_teleport
	name = "Niesamowity ruch"
	desc = "Wejdź na inny plan istnienia, na którym przenikasz przez ściany, albo z niego wyjdź. Możesz to zrobić tylko wtedy, gdy nikt cię nie widzi."
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "blink"
	background_icon_state = "bg_default"
	/// Component which prevents this action being used while visible
	var/datum/component/unobserved_actor/observed_blocker

/datum/action/cooldown/spell/jaunt/creature_teleport/Grant(mob/grant_to)
	. = ..()
	if (!owner)
		return
	observed_blocker = owner.AddComponent(/datum/component/unobserved_actor, unobserved_flags = NO_OBSERVED_ACTIONS, affected_actions = list(type))

/datum/action/cooldown/spell/jaunt/creature_teleport/Remove(mob/living/remove_from)
	QDEL_NULL(observed_blocker)
	return ..()

/datum/action/cooldown/spell/jaunt/creature_teleport/before_cast(atom/cast_on)
	. = ..()
	if (. & SPELL_CANCEL_CAST)
		return
	if (!owner || !do_after(owner, 6 SECONDS, target = owner.loc))
		owner?.balloon_alert(owner, "przerwano!")
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/jaunt/creature_teleport/cast(atom/cast_on)
	. = ..()
	playsound(get_turf(owner), 'sound/effects/podwoosh.ogg', 50, TRUE, -1)
	if(is_jaunting(cast_on))
		exit_jaunt(cast_on)
		return
	enter_jaunt(cast_on)

/mob/living/basic/migo
	name = "mi-go"
	desc = "Różowawa, grzybopodobna istota przypominająca skorupiaka, z licznymi parami szponiastych odnóży i głową pokrytą falującymi czułkami."
	icon_state = "mi-go"
	icon_living = "mi-go"
	icon_dead = "mi-go-dead"
	health = 80
	maxHealth = 80
	obj_damage = 100
	melee_damage = 35
	speed = -0.5
	attack_verb_continuous = "rozszarpuje"
	melee_attack_cooldown = 1 SECONDS
	gold_core_spawnable = HOSTILE_SPAWN
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	faction = list("nether")
	speak_emote = list("krzyczy", "klika", "terkocze", "szczeka", "jęczy", "warczy", "miauczy", "dudni", "ryczy", "piszczy", "grzechocze", "woła", "wrzeszczy", "zauważa", "mamrocze", "trajkocze", "jąka się", "kipi złością")
	death_message = "zawodzi, gdy jego forma zamienia się w papkę."
	death_sound = 'sound/voice/hiss6.ogg'
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	discovery_points = 3000
	ai_controller = /datum/ai_controller/basic_controller/simple_hostile_obstacles
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	var/static/list/migo_sounds
	/// Odds migo will dodge
	var/dodge_prob = 10
	/// Are we dodging an attack during this move?
	var/dodging = FALSE

/mob/living/basic/migo/Initialize(mapload)
	. = ..()
	if(!migo_sounds)
		migo_sounds = list('sound/items/bubblewrap.ogg', 'sound/items/change_jaws.ogg', 'sound/items/crowbar.ogg', 'sound/items/drink.ogg', 'sound/items/deconstruct.ogg', 'sound/items/carhorn.ogg', 'sound/items/change_drill.ogg', 'sound/items/dodgeball.ogg', 'sound/items/eatfood.ogg', 'sound/items/megaphone.ogg', 'sound/items/screwdriver.ogg', 'sound/items/weeoo1.ogg', 'sound/items/wirecutter.ogg', 'sound/items/welder.ogg', 'sound/items/zip.ogg', 'sound/items/rped.ogg', 'sound/items/ratchet.ogg', 'sound/items/polaroid1.ogg', 'sound/items/pshoom.ogg', 'sound/items/airhorn.ogg', 'sound/items/geiger/high1.ogg', 'sound/items/geiger/high2.ogg', 'aquila/sound/voice/beepsky/creep.ogg', 'aquila/sound/voice/beepsky/iamthelaw.ogg', 'sound/voice/ed209_20sec.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss6.ogg', 'sound/voice/medbot/patchedup.ogg', 'sound/voice/medbot/feelbetter.ogg', 'sound/voice/human/manlaugh1.ogg', 'sound/voice/human/womanlaugh.ogg', 'sound/weapons/sear.ogg', 'sound/ambience/antag/clockcultalr.ogg', 'sound/ambience/antag/ling_aler.ogg', 'sound/ambience/antag/tatoralert.ogg', 'sound/ambience/antag/monkey.ogg', 'sound/mecha/nominal.ogg', 'sound/mecha/weapdestr.ogg', 'sound/mecha/critdestr.ogg', 'sound/mecha/imag_enh.ogg', 'sound/effects/adminhelp.ogg', 'sound/effects/alert.ogg', 'sound/effects/attackblob.ogg', 'sound/effects/bamf.ogg', 'sound/effects/blobattack.ogg', 'sound/effects/break_stone.ogg', 'sound/effects/bubbles.ogg', 'sound/effects/bubbles2.ogg', 'sound/effects/clang.ogg', 'sound/effects/clockcult_gateway_disrupted.ogg', 'sound/effects/clownstep2.ogg', 'sound/effects/curse1.ogg', 'sound/effects/dimensional_rend.ogg', 'sound/effects/doorcreaky.ogg', 'sound/effects/empulse.ogg', 'sound/effects/explosion_distant.ogg', 'sound/effects/explosionfar.ogg', 'sound/effects/explosion1.ogg', 'sound/effects/grillehit.ogg', 'sound/effects/genetics.ogg', 'sound/effects/heart_beat.ogg', 'sound/effects/hyperspace_begin.ogg', 'sound/effects/hyperspace_end.ogg', 'sound/effects/his_grace_awaken.ogg', 'sound/effects/pai_boot.ogg', 'sound/effects/phasein.ogg', 'sound/effects/picaxe1.ogg', 'sound/effects/ratvar_reveal.ogg', 'sound/effects/sparks1.ogg', 'sound/effects/smoke.ogg', 'sound/effects/splat.ogg', 'sound/effects/snap.ogg', 'sound/effects/tendril_destroyed.ogg', 'sound/effects/supermatter.ogg', 'sound/misc/desecration-01.ogg', 'sound/misc/desecration-02.ogg', 'sound/misc/desecration-03.ogg', 'sound/misc/bloblarm.ogg', 'sound/misc/airraid.ogg', 'sound/misc/bang.ogg','sound/misc/highlander.ogg', 'sound/misc/interference.ogg', 'sound/misc/notice1.ogg', 'sound/misc/notice2.ogg', 'sound/misc/sadtrombone.ogg', 'sound/misc/slip.ogg', 'sound/misc/splort.ogg', 'sound/weapons/armbomb.ogg', 'sound/weapons/beam_sniper.ogg', 'sound/weapons/chainsawhit.ogg', 'sound/weapons/emitter.ogg', 'sound/weapons/emitter2.ogg', 'sound/weapons/blade1.ogg', 'sound/weapons/bladeslice.ogg', 'sound/weapons/blastcannon.ogg', 'sound/weapons/blaster.ogg', 'sound/weapons/bulletflyby3.ogg', 'sound/weapons/circsawhit.ogg', 'sound/weapons/cqchit2.ogg', 'sound/weapons/drill.ogg', 'sound/weapons/genhit1.ogg', 'sound/weapons/handcuffs.ogg', 'sound/weapons/homerun.ogg', 'sound/weapons/kenetic_accel.ogg', 'sound/machines/clockcult/steam_whoosh.ogg', 'sound/machines/fryer/deep_fryer_emerge.ogg', 'sound/machines/airlock.ogg', 'sound/machines/airlock_alien_prying.ogg', 'sound/machines/airlockclose.ogg', 'sound/machines/airlockforced.ogg', 'sound/machines/airlockopen.ogg', 'sound/machines/alarm.ogg', 'sound/machines/blender.ogg', 'sound/machines/boltsdown.ogg', 'sound/machines/boltsup.ogg', 'sound/machines/buzz-sigh.ogg', 'sound/machines/buzz-two.ogg', 'sound/machines/chime.ogg', 'sound/machines/cryo_warning.ogg', 'sound/machines/defib_charge.ogg', 'sound/machines/defib_failed.ogg', 'sound/machines/defib_ready.ogg', 'sound/machines/defib_zap.ogg', 'sound/machines/deniedbeep.ogg', 'sound/machines/ding.ogg', 'sound/machines/disposalflush.ogg', 'sound/machines/door_close.ogg', 'sound/machines/door_open.ogg', 'sound/machines/engine_alert1.ogg', 'sound/machines/engine_alert2.ogg', 'sound/machines/hiss.ogg', 'sound/machines/honkbot_evil_laugh.ogg', 'sound/machines/juicer.ogg', 'sound/machines/ping.ogg', 'sound/ambience/signal.ogg', 'sound/machines/synth_no.ogg', 'sound/machines/synth_yes.ogg', 'sound/machines/terminal_alert.ogg', 'sound/machines/triple_beep.ogg', 'sound/machines/twobeep.ogg', 'sound/machines/ventcrawl.ogg', 'sound/machines/warning-buzzer.ogg', 'sound/ai/default/outbreak5.ogg', 'sound/ai/default/outbreak7.ogg', 'sound/ai/default/poweroff.ogg', 'sound/ai/default/radiation.ogg', 'sound/ai/default/shuttlecalled.ogg', 'sound/ai/default/shuttledock.ogg', 'sound/ai/default/shuttlerecalled.ogg', 'sound/ai/default/aimalf.ogg') //hahahaha fuck you code divers
	AddComponent(/datum/component/health_scaling_effects, min_health_slowdown = -1.5, additional_status_callback = CALLBACK(src, PROC_REF(update_dodge_chance)))

/// Makes the migo more likely to dodge around the more damaged it is
/mob/living/basic/migo/proc/update_dodge_chance(health_ratio)
	dodge_prob = 50 + (10 - 50) * health_ratio

/mob/living/basic/migo/proc/make_migo_sound()
	playsound(src, pick(migo_sounds), 50, TRUE)

/mob/living/basic/migo/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	. = ..()
	if(stat != CONSCIOUS)
		return
	make_migo_sound()

/mob/living/basic/migo/Life(seconds, times_fired)
	. = ..()
	if(stat != CONSCIOUS)
		return
	if(DT_PROB(5, seconds))
		make_migo_sound()

/mob/living/basic/migo/Move(atom/newloc, dir, step_x, step_y)
	if(!dodging && !ckey && prob(dodge_prob) && moving_diagonally == 0 && isturf(loc) && isturf(newloc))
		return dodge(newloc, dir)
	return ..()

/// Swerves sideways on the way to the target
/mob/living/basic/migo/proc/dodge(moving_to, move_direction)
	var/cdir = turn(move_direction, 45)
	var/ccdir = turn(move_direction, -45)
	dodging = TRUE
	. = Move(get_step(loc, pick(cdir, ccdir)))
	if(!.)//Can't dodge there so we just carry on
		. = Move(moving_to, move_direction)
	dodging = FALSE

/mob/living/basic/blankbody
	name = "puste ciało"
	desc = "Wygląda dość po ludzku, ale skóra ma popielatą fakturę, a twarz jest pozbawiona rysów, nie licząc upiornego uśmiechu."
	icon_state = "blank-body"
	icon_living = "blank-body"
	icon_dead = "blank-dead"
	health = 100
	maxHealth = 100
	obj_damage = 100
	melee_damage = 10
	attack_verb_continuous = "uderza"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	melee_attack_cooldown = 1 SECONDS
	faction = list("nether")
	speak_emote = list("krzyczy")
	death_message = "rozpada się w drobny pył."
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	discovery_points = 3000
	ai_controller = /datum/ai_controller/basic_controller/simple_hostile_obstacles
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)

/mob/living/basic/blankbody/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/health_scaling_effects, min_health_attack_modifier_lower = 8, min_health_attack_modifier_upper = 14)

/obj/structure/spawner/nether
	name = "łącze z zaświatami"
	desc = null //see examine()
	icon_state = "nether"
	max_integrity = 50
	spawn_time = 600 //1 minute
	max_mobs = 15
	icon = 'icons/mob/nest.dmi'
	spawn_text = "przeczołguje się przez"
	mob_types = list(/mob/living/basic/migo, /mob/living/basic/creature, /mob/living/basic/blankbody)
	faction = list("nether")

/obj/structure/spawner/nether/Initialize(mapload)
	.=..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/spawner/nether/examine(mob/user)
	. = ..()
	if(isskeleton(user) || iszombie(user))
		. += "Bezpośrednie połączenie z innym wymiarem, pełnym istot bardzo szczęśliwych na twój widok. <span class='nicegreen'>Stąd widać twój dom!</span>"
	else
		. += "Bezpośrednie połączenie z innym wymiarem, pełnym istot niezbyt szczęśliwych na twój widok. <span class='warning'>Wejście w nie byłoby bardzo złym pomysłem.</span>"

/obj/structure/spawner/nether/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(isskeleton(user) || iszombie(user))
		to_chat(user, "<span class='notice'>Jeszcze nie masz ochoty wracać do domu...</span>")
	else
		user.visible_message("<span class='warning'>[user] zostaje gwałtownie wciągnięty w połączenie!</span>", \
							"<span class='userdanger'>Gdy dotykasz portalu, zostajesz błyskawicznie wciągnięty do świata niewyobrażalnej grozy!</span>")
		contents.Add(user)

/obj/structure/spawner/nether/process(delta_time)
	for(var/mob/living/M in contents)
		if(M)
			playsound(src, 'sound/magic/demon_consume.ogg', 50, 1)
			M.adjustBruteLoss(60 * delta_time)
			new /obj/effect/gibspawner/generic(get_turf(M), M)
			if(M.stat == DEAD)
				var/mob/living/basic/blankbody/blank
				blank = new(loc)
				blank.name = "[M]"
				blank.desc = "To [M], ale skóra ma popielatą fakturę, a twarz jest pozbawiona rysów, nie licząc upiornego uśmiechu."
				src.visible_message("<span class='warning'>[M] wyłania się z połączenia!</span>")
				qdel(M)
