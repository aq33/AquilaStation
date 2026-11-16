// AQUILA - minigra łowienia: port /datum/fishing_challenge i /datum/fish_movement z tg (code/modules/fishing/
// fishing_minigame.dm i fish_movement.dm, ikony icons/hud/fishing_hud.dmi, CC BY-SA 3.0; dźwięki chlupnięć z tg).
// Przebieg jak w tg: spławik czeka (kliknięcie za wcześnie przedłuża czekanie), potem bierze (!!!) i trzeba kliknąć
// w ciągu 4 sekund. Wtedy obok ekranu pojawia się pasek: przytrzymany przycisk myszy podciąga przynętę w górę,
// puszczony opuszcza ją w dół, a postęp rośnie, póki ryba jest w polu przynęty. 100% = ryba złowiona, 0% = uciekła.
// Działa tak samo w combat mode i na intencjach (kliknięcia podczas łowienia nie trafiają w świat).
// Uproszczenia względem tg: bez efektów aktywnych (antygrawitacja, kamuflaż), żyłek i haczyków, umiejętności i
// doświadczenia, spinningu przynęt, osiągnięć; ruchy ryb tylko podstawowy, „slow” i „zippy”.

#define WAIT_PHASE 1
#define BITING_PHASE 2
#define MINIGAME_PHASE 3
/// Najmniejsza prędkość, przy której przynęta odbija się od krawędzi
#define BAIT_MIN_VELOCITY_BOUNCE 150
/// Spadek początkowego postępu przy wysokiej trudności
#define MAX_FISH_COMPLETION_MALUS 15
/// Czas na kliknięcie po braniu
#define BITING_TIME_WINDOW (4 SECONDS)
/// O ile trudność skraca pasek przynęty
#define BAIT_HEIGHT_DIFFICULTY_MALUS 1.3
#define REELING_STATE_IDLE 0
#define REELING_STATE_UP 1
/// Wymiary paska minigry w pikselach
#define MINIGAME_SLIDER_HEIGHT 76
#define MINIGAME_BAIT_HEIGHT 27
#define MINIGAME_BAIT_TOP_AND_BOTTOM_HEIGHT 6
#define MINIGAME_COMPLETION_BAR_HEIGHT 80

/// Bieżące łowienie gracza (gracz -> łowienie)
GLOBAL_LIST_EMPTY(fishing_challenges_by_user)

PROCESSING_SUBSYSTEM_DEF(fishing)
	name = "Wędkarstwo"
	flags = SS_BACKGROUND | SS_POST_FIRE_TIMING | SS_NO_INIT
	wait = 1

/datum/fishing_challenge
	/// Kiedy zaczęła się minigra
	var/start_time
	/// Czy już się skończyło
	var/completed = FALSE
	/// Wylosowana zdobycz (typ zachowania ryby, przedmiotu albo FISHING_DUD)
	var/reward_path = FISHING_DUD
	var/difficulty = FISHING_DEFAULT_DIFFICULTY
	var/phase = WAIT_PHASE
	var/next_phase_timer
	/// Zakres czekania na branie
	var/list/wait_time_range = list(3 SECONDS, 25 SECONDS)
	/// Ostatnie kliknięcie w fazie czekania (podwójne kliknięcie nie karze)
	var/last_baiting_click = 0
	var/mob/living/user
	var/obj/item/fishing_rod/used_rod
	/// Spławik i pole, nad którym wisi
	var/obj/effect/fishing_float/float
	var/atom/location
	var/datum/fish_source/fish_source
	/// Tło i ikona ryby w minigrze
	var/background = "background_default"
	var/fish_icon = "fish"
	var/datum/beam/fishing_line
	/// Stan minigry (jak w tg, w jednostkach FISHING_MINIGAME_AREA)
	var/fish_height = 50
	var/bait_height = 360
	var/bait_pixel_height = MINIGAME_BAIT_HEIGHT
	var/fish_position = 0
	var/bait_position = 0
	var/bait_velocity = 0
	var/completion = 30
	var/completion_loss = 6
	var/completion_gain = 5
	var/datum/fish_movement/mover
	var/reeling_state = REELING_STATE_IDLE
	var/gravity_velocity = -800
	var/reeling_velocity = 1200
	var/bait_bounce_mult = 0.6
	var/deceleration_mult = 1.8
	var/overlap_velocity_mult = 0.6
	var/atom/movable/screen/fishing_hud/fishing_hud

/datum/fishing_challenge/New(atom/spot, obj/item/fishing_rod/rod, mob/living/new_user, datum/fish_source/source)
	user = new_user
	used_rod = rod
	location = spot
	fish_source = source
	background = source.background
	float = new(get_turf(location))
	GLOB.fishing_challenges_by_user[user] = src
	RegisterSignal(location, COMSIG_PARENT_QDELETING, PROC_REF(interrupt))
	reeling_velocity *= rod.bait_speed_mult
	completion_gain *= rod.completion_speed_mult
	bait_height *= rod.bait_height_mult
	overlap_velocity_mult = overlap_velocity_mult ** rod.bait_speed_mult

/datum/fishing_challenge/Destroy(force)
	GLOB.fishing_challenges_by_user -= user
	if(!completed)
		complete(FALSE)
	if(fishing_line)
		UnregisterSignal(fishing_line, COMSIG_PARENT_QDELETING)
		QDEL_NULL(fishing_line)
	QDEL_NULL(float)
	QDEL_NULL(mover)
	user = null
	used_rod = null
	location = null
	fish_source = null
	return ..()

/datum/fishing_challenge/proc/start()
	fishing_line = used_rod.create_fishing_line(float, user)
	if(!fishing_line)
		qdel(src)
		return
	RegisterSignal(fishing_line, COMSIG_PARENT_QDELETING, PROC_REF(on_line_deleted))
	RegisterSignal(used_rod, COMSIG_ITEM_DROPPED, PROC_REF(interrupt))
	RegisterSignal(user, COMSIG_MOB_CLICKON, PROC_REF(handle_click))
	RegisterSignal(user, COMSIG_MOB_LOGOUT, PROC_REF(interrupt))
	RegisterSignal(user, COMSIG_MOB_STATCHANGE, PROC_REF(on_user_stat_change))
	ADD_TRAIT(user, TRAIT_GONE_FISHING, REF(src))
	start_baiting_phase()
	to_chat(user, span_notice("Zarzucasz wędkę i czekasz na branie..."))
	playsound(location, 'sound/effects/splash.ogg', 100)

/datum/fishing_challenge/proc/send_alert(message)
	location?.balloon_alert(user, message)

/datum/fishing_challenge/proc/on_line_deleted(datum/source)
	SIGNAL_HANDLER
	fishing_line = null
	user?.balloon_alert(user, "żyłka się zerwała")
	interrupt()

/// Śmierć albo utrata przytomności kończy łowienie
/datum/fishing_challenge/proc/on_user_stat_change(mob/living/source, new_stat)
	SIGNAL_HANDLER
	if(new_stat != CONSCIOUS)
		interrupt()

/// Kliknięcia podczas łowienia sterują łowieniem, a nie trafiają w świat. ClickOn wysyła już sparsowaną listę modyfikatorów.
/datum/fishing_challenge/proc/handle_click(mob/living/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(LAZYACCESS(modifiers, SHIFT_CLICK) || LAZYACCESS(modifiers, CTRL_CLICK) || LAZYACCESS(modifiers, ALT_CLICK))
		return
	if(source.get_active_held_item() != used_rod)
		return
	if(phase == WAIT_PHASE)
		if(world.time < last_baiting_click + 0.25 SECONDS)
			return COMSIG_MOB_CANCEL_CLICKON
		send_alert("za wcześnie!")
		start_baiting_phase(TRUE)
	else if(phase == BITING_PHASE)
		INVOKE_ASYNC(src, PROC_REF(start_minigame_phase))
	return COMSIG_MOB_CANCEL_CLICKON

/datum/fishing_challenge/proc/interrupt()
	SIGNAL_HANDLER
	if(!completed)
		complete(FALSE)

/datum/fishing_challenge/proc/complete(win = FALSE)
	if(completed)
		return
	deltimer(next_phase_timer)
	completed = TRUE
	if(phase == MINIGAME_PHASE)
		remove_minigame_hud()
		used_rod?.consume_bait()
	if(user)
		UnregisterSignal(user, list(COMSIG_MOB_CLICKON, COMSIG_MOB_LOGOUT))
		REMOVE_TRAIT(user, TRAIT_GONE_FISHING, REF(src))
	if(used_rod)
		UnregisterSignal(used_rod, COMSIG_ITEM_DROPPED)
	if(win && reward_path != FISHING_DUD)
		playsound(location, 'aquila/sound/effects/fishing/bigsplash.ogg', 100)
	else if(!win && user)
		user.balloon_alert(user, "uciekła!")
	SEND_SIGNAL(src, COMSIG_FISHING_CHALLENGE_COMPLETED, user, win)
	if(!QDELETED(src))
		qdel(src)

/datum/fishing_challenge/proc/start_baiting_phase(penalty = FALSE)
	reward_path = null
	last_baiting_click = world.time
	var/wait_time
	if(penalty)
		wait_time = min(timeleft(next_phase_timer) + rand(3 SECONDS, 5 SECONDS), 30 SECONDS)
	else
		wait_time = rand(wait_time_range[1], wait_time_range[2])
	deltimer(next_phase_timer)
	phase = WAIT_PHASE
	animate(float, pixel_y = 1, time = 1 SECONDS, loop = -1, flags = ANIMATION_RELATIVE)
	animate(pixel_y = -1, time = 1 SECONDS, flags = ANIMATION_RELATIVE)
	next_phase_timer = addtimer(CALLBACK(src, PROC_REF(start_biting_phase)), wait_time, TIMER_STOPPABLE)

/datum/fishing_challenge/proc/start_biting_phase()
	phase = BITING_PHASE
	reward_path = fish_source.roll_reward(used_rod, user)
	if(ispath(reward_path, /datum/aquarium_behaviour/fish))
		var/datum/aquarium_behaviour/fish/fish = reward_path
		fish_icon = initial(fish.fishing_hud_icon)
	playsound(location, 'aquila/sound/effects/fishing/fish_splash.ogg', 100)
	send_alert("!!!")
	animate(float, pixel_y = 3, time = 5, loop = -1, flags = ANIMATION_RELATIVE)
	animate(pixel_y = -3, time = 5, flags = ANIMATION_RELATIVE)
	next_phase_timer = addtimer(CALLBACK(src, PROC_REF(start_baiting_phase)), BITING_TIME_WINDOW, TIMER_STOPPABLE)

/// Branie złapane: pusty zarzut kończy od razu, ryba zaczyna minigrę
/datum/fishing_challenge/proc/start_minigame_phase()
	if(phase != BITING_PHASE || completed)
		return
	var/time_left = timeleft(next_phase_timer)
	deltimer(next_phase_timer)
	if(reward_path == FISHING_DUD)
		complete(TRUE)
		return
	difficulty = fish_source.calculate_difficulty(reward_path, used_rod, user)
	if(difficulty > FISHING_DEFAULT_DIFFICULTY)
		completion -= MAX_FISH_COMPLETION_MALUS * (difficulty * 0.01)
	// Szybka reakcja na branie daje lepszy start (jak w tg)
	switch(time_left)
		if(0 to BITING_TIME_WINDOW - 3 SECONDS)
			completion *= 0.65
		if(BITING_TIME_WINDOW - 3 SECONDS to BITING_TIME_WINDOW - 2 SECONDS)
			completion *= 0.82
		if(BITING_TIME_WINDOW - 1 SECONDS to BITING_TIME_WINDOW - 0.5 SECONDS)
			completion *= 1.2
		if(BITING_TIME_WINDOW - 0.5 SECONDS to BITING_TIME_WINDOW)
			completion *= 1.4
	var/movement_path = /datum/fish_movement
	if(ispath(reward_path, /datum/aquarium_behaviour/fish))
		var/datum/aquarium_behaviour/fish/fish = reward_path
		movement_path = initial(fish.fish_movement_type)
	mover = new movement_path(src)
	fish_position = rand(0, (FISHING_MINIGAME_AREA - fish_height) * 0.8)
	var/diff_dist = 100 + difficulty
	bait_position = clamp(round(fish_position + rand(-diff_dist, diff_dist) - bait_height * 0.5), 0, FISHING_MINIGAME_AREA - bait_height)
	phase = MINIGAME_PHASE
	start_time = world.time
	if(!user.client)
		complete(FALSE)
		return
	mover.adjust_to_difficulty()
	bait_height -= round(difficulty * BAIT_HEIGHT_DIFFICULTY_MALUS)
	bait_pixel_height = round(MINIGAME_BAIT_HEIGHT * (bait_height / initial(bait_height)), 1)
	fishing_hud = new
	fishing_hud.prepare_minigame(src)
	RegisterSignal(user.client, COMSIG_CLIENT_MOUSEDOWN, PROC_REF(start_reeling))
	RegisterSignal(user.client, COMSIG_CLIENT_MOUSEUP, PROC_REF(stop_reeling))
	START_PROCESSING(SSfishing, src)

/datum/fishing_challenge/proc/remove_minigame_hud()
	STOP_PROCESSING(SSfishing, src)
	if(user?.client)
		UnregisterSignal(user.client, list(COMSIG_CLIENT_MOUSEDOWN, COMSIG_CLIENT_MOUSEUP))
	QDEL_NULL(fishing_hud)

/datum/fishing_challenge/proc/start_reeling(client/source, object, location, control, params)
	SIGNAL_HANDLER
	reeling_state = REELING_STATE_UP

/datum/fishing_challenge/proc/stop_reeling(client/source, object, location, control, params)
	SIGNAL_HANDLER
	reeling_state = REELING_STATE_IDLE

/datum/fishing_challenge/process(delta_time)
	mover.move_fish(delta_time)
	move_bait(delta_time)
	if(!completed && !QDELETED(fishing_hud))
		update_visuals(delta_time)

/// Ruch przynęty: holowanie w górę, opadanie w dół, odbicia od krawędzi, postęp przy rybie w polu przynęty
/datum/fishing_challenge/proc/move_bait(delta_time)
	var/should_bounce = abs(bait_velocity) > BAIT_MIN_VELOCITY_BOUNCE
	bait_position += bait_velocity * delta_time
	if(bait_position > FISHING_MINIGAME_AREA - bait_height)
		bait_position = FISHING_MINIGAME_AREA - bait_height
		if(reeling_state == REELING_STATE_UP || !should_bounce)
			bait_velocity = 0
		else
			bait_velocity = -bait_velocity * bait_bounce_mult
	else if(bait_position < 0)
		bait_position = 0
		if(!should_bounce)
			bait_velocity = 0
		else
			bait_velocity = -bait_velocity * bait_bounce_mult

	var/fish_on_bait = (fish_position + fish_height >= bait_position) && (bait_position + bait_height >= fish_position)
	var/velocity_change = reeling_state == REELING_STATE_UP ? reeling_velocity : gravity_velocity
	velocity_change = round(velocity_change * (fish_on_bait ? overlap_velocity_mult : 1) * delta_time)
	// Hamowanie przy zmianie kierunku: przynęta mniej się ślizga
	if(bait_velocity > 0 && velocity_change < 0)
		bait_velocity += max(-bait_velocity, velocity_change * deceleration_mult)
	else if(bait_velocity < 0 && velocity_change > 0)
		bait_velocity += min(-bait_velocity, velocity_change * deceleration_mult)
	bait_velocity += velocity_change

	if(fish_on_bait)
		completion += completion_gain * delta_time
		if(completion >= 100)
			complete(TRUE)
			return
	else
		completion -= completion_loss * delta_time
		if(completion <= 0)
			complete(FALSE)
			return
	completion = clamp(completion, 0, 100)

/datum/fishing_challenge/proc/update_visuals(delta_time)
	animate(fishing_hud.hud_bait, pixel_y = MINIGAME_SLIDER_HEIGHT * (bait_position / FISHING_MINIGAME_AREA), time = delta_time SECONDS)
	animate(fishing_hud.hud_fish, pixel_y = MINIGAME_SLIDER_HEIGHT * (fish_position / FISHING_MINIGAME_AREA), time = delta_time SECONDS)
	fishing_hud.hud_completion.update_state(completion, delta_time)

/// Spławik nad łowiskiem
/obj/effect/fishing_float
	name = "spławik"
	icon = 'aquila/icons/planets/water/fishing.dmi'
	icon_state = "float"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_MOB_LAYER

/// Pasek minigry obok środka ekranu: tło, ramka wędki, przynęta, ryba i pasek postępu
/atom/movable/screen/fishing_hud
	icon = 'aquila/icons/planets/water/fishing_hud.dmi'
	screen_loc = "CENTER+1:8,CENTER:2"
	name = "łowienie"
	appearance_flags = APPEARANCE_UI | KEEP_TOGETHER
	var/atom/movable/screen/hud_fish/hud_fish
	var/atom/movable/screen/hud_bait/hud_bait
	var/atom/movable/screen/hud_completion/hud_completion
	var/client/owner_client

/atom/movable/screen/fishing_hud/proc/prepare_minigame(datum/fishing_challenge/challenge)
	icon_state = challenge.background
	add_overlay(challenge.used_rod?.frame_state || "frame_wood")
	hud_bait = new
	hud_bait.cur_height = challenge.bait_pixel_height
	hud_bait.update_icon()
	hud_fish = new
	hud_fish.icon_state = challenge.fish_icon
	hud_completion = new
	vis_contents += list(hud_bait, hud_fish, hud_completion)
	owner_client = challenge.user.client
	owner_client.screen += src
	challenge.update_visuals(0)

/atom/movable/screen/fishing_hud/Destroy()
	owner_client?.screen -= src
	owner_client = null
	vis_contents.Cut()
	QDEL_NULL(hud_fish)
	QDEL_NULL(hud_bait)
	QDEL_NULL(hud_completion)
	return ..()

/atom/movable/screen/hud_bait
	icon = 'aquila/icons/planets/water/fishing_hud.dmi'
	icon_state = "bait_bottom"
	vis_flags = VIS_INHERIT_ID
	var/cur_height = MINIGAME_BAIT_HEIGHT

/atom/movable/screen/hud_bait/update_overlays()
	. = ..()
	var/mutable_appearance/bait_top = mutable_appearance(icon, "bait_top")
	bait_top.pixel_y += cur_height - MINIGAME_BAIT_TOP_AND_BOTTOM_HEIGHT
	. += bait_top
	for(var/i in 1 to (cur_height - MINIGAME_BAIT_TOP_AND_BOTTOM_HEIGHT))
		var/mutable_appearance/bait_bar = mutable_appearance(icon, "bait_bar")
		bait_bar.pixel_y += i
		. += bait_bar

/atom/movable/screen/hud_fish
	icon = 'aquila/icons/planets/water/fishing_hud.dmi'
	icon_state = "fish"
	vis_flags = VIS_INHERIT_ID

/atom/movable/screen/hud_completion
	icon = 'aquila/icons/planets/water/fishing_hud.dmi'
	icon_state = "completion_overlay"
	vis_flags = VIS_INHERIT_ID

/atom/movable/screen/hud_completion/Initialize(mapload)
	. = ..()
	add_filter("completion_mask", 1, alpha_mask_filter(icon = icon(icon, "completion_overlay")))

/atom/movable/screen/hud_completion/proc/update_state(completion, delta_time)
	animate(get_filter("completion_mask"), y = -MINIGAME_COMPLETION_BAR_HEIGHT * (1 - completion * 0.01), time = delta_time SECONDS)

/// Kliknięcia myszy dla minigry (przytrzymanie przycisku = holowanie)
/client/MouseDown(object, location, control, params)
	SEND_SIGNAL(src, COMSIG_CLIENT_MOUSEDOWN, object, location, control, params)
	return ..()

/client/MouseUp(object, location, control, params)
	SEND_SIGNAL(src, COMSIG_CLIENT_MOUSEUP, object, location, control, params)
	return ..()

// Ruch ryby w minigrze (tg fish_movement.dm)

#define FISH_TARGET_MIN_DISTANCE 6
#define FISH_FRICTION_MULT 0.9
#define FISH_SHORT_JUMP_MIN_DISTANCE 100
#define FISH_SHORT_JUMP_MAX_DISTANCE 200

/datum/fish_movement
	var/datum/fishing_challenge/master
	var/times_fired = 0
	var/short_jump_chance = 2.25
	var/long_jump_chance = 0.0625
	var/short_jump_velocity_limit = 400
	var/long_jump_velocity_limit = 200
	var/current_velocity_limit
	var/target_position
	var/can_interrupt_move = TRUE
	var/fish_velocity = 0

/datum/fish_movement/New(datum/fishing_challenge/new_master)
	master = new_master

/datum/fish_movement/Destroy(force)
	master = null
	return ..()

/// Szanse skoków rosną z trudnością po krzywej (jak w tg)
/datum/fish_movement/proc/adjust_to_difficulty()
	var/square_angle_rad = TORADIANS(90)
	var/zero_one_difficulty = master.difficulty / 100
	if(short_jump_chance > 1)
		short_jump_chance = (zero_one_difficulty ** (square_angle_rad - TORADIANS(arctan(short_jump_chance * 1 / square_angle_rad)))) * 100
	else
		short_jump_chance *= master.difficulty
	if(long_jump_chance > 1)
		long_jump_chance = (zero_one_difficulty ** (square_angle_rad - TORADIANS(arctan(long_jump_chance * 1 / square_angle_rad)))) * 100
	else
		long_jump_chance *= master.difficulty

/datum/fish_movement/proc/move_fish(delta_time)
	times_fired++
	var/can_roll = times_fired % 2
	if(!isnull(target_position) && abs(target_position - master.fish_position) < FISH_TARGET_MIN_DISTANCE)
		target_position = null
	// Długi skok
	if(can_roll && (can_interrupt_move || isnull(target_position)) && prob(long_jump_chance))
		var/distance_from_top = FISHING_MINIGAME_AREA - master.fish_position - master.fish_height
		var/distance_from_bottom = master.fish_position
		var/top_chance = distance_from_top < FISH_SHORT_JUMP_MIN_DISTANCE ? 0 : (distance_from_top / max(distance_from_bottom, 1)) * 100
		var/new_target = master.fish_position
		if(prob(top_chance))
			new_target += distance_from_top * rand(75, 100) / 100
		else
			new_target -= distance_from_bottom * rand(75, 100) / 100
		target_position = round(new_target)
		current_velocity_limit = long_jump_velocity_limit
	// Ruch do celu
	if(!isnull(target_position))
		var/distance = target_position - master.fish_position
		var/acceleration_mult = 0.3 * master.difficulty + 0.5
		fish_velocity = fish_velocity * FISH_FRICTION_MULT + distance * acceleration_mult * delta_time
	else if(can_roll && prob(short_jump_chance))
		var/distance_from_top = FISHING_MINIGAME_AREA - master.fish_position - master.fish_height
		var/distance_from_bottom = master.fish_position
		var/jump_length = 0
		if(distance_from_top >= FISH_SHORT_JUMP_MIN_DISTANCE)
			jump_length = rand(FISH_SHORT_JUMP_MIN_DISTANCE, FISH_SHORT_JUMP_MAX_DISTANCE)
		if(distance_from_bottom >= FISH_SHORT_JUMP_MIN_DISTANCE && (!jump_length || prob(50)))
			jump_length = -rand(FISH_SHORT_JUMP_MIN_DISTANCE, FISH_SHORT_JUMP_MAX_DISTANCE)
		target_position = clamp(master.fish_position + jump_length, 0, FISHING_MINIGAME_AREA - master.fish_height)
		current_velocity_limit = short_jump_velocity_limit
	fish_velocity = clamp(fish_velocity, -current_velocity_limit, current_velocity_limit)
	master.fish_position = clamp(master.fish_position + fish_velocity * delta_time, 0, FISHING_MINIGAME_AREA - master.fish_height)

/// Wolne, nieprzerywane długie skoki
/datum/fish_movement/slow
	short_jump_chance = 0
	long_jump_chance = 1.5
	long_jump_velocity_limit = 150
	can_interrupt_move = FALSE

/// Trzy razy częstsze krótkie skoki
/datum/fish_movement/zippy
	short_jump_chance = 6.75

#undef FISH_TARGET_MIN_DISTANCE
#undef FISH_FRICTION_MULT
#undef FISH_SHORT_JUMP_MIN_DISTANCE
#undef FISH_SHORT_JUMP_MAX_DISTANCE
#undef WAIT_PHASE
#undef BITING_PHASE
#undef MINIGAME_PHASE
#undef BAIT_MIN_VELOCITY_BOUNCE
#undef MAX_FISH_COMPLETION_MALUS
#undef BITING_TIME_WINDOW
#undef BAIT_HEIGHT_DIFFICULTY_MALUS
#undef REELING_STATE_IDLE
#undef REELING_STATE_UP
#undef MINIGAME_SLIDER_HEIGHT
#undef MINIGAME_BAIT_HEIGHT
#undef MINIGAME_BAIT_TOP_AND_BOTTOM_HEIGHT
#undef MINIGAME_COMPLETION_BAR_HEIGHT
