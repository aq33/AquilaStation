// AQUILA - ustawienia graczy do reworku strzelania (okno: tgui/.../game_preferences/gunplay.tsx)

/datum/preferences
	/// Kursor pokazujący rozrzut trzymanej broni
	var/gun_cursor = TRUE
	/// Postać w combat mode patrzy na kursor (także w ruchu)
	var/face_cursor_combat = TRUE
	/// Siła kopnięcia kamery od odrzutu, w procentach
	var/recoil_camera_strength = 100

/datum/preference/toggle/player/gun_cursor
	db_key = "gun_cursor"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "gun_cursor"

/datum/preference/toggle/player/gun_cursor/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	if(isliving(C?.mob))
		var/mob/living/living_mob = C.mob
		living_mob.update_gun_cursor()

/datum/preference/toggle/player/face_cursor_combat
	db_key = "face_cursor_combat"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "face_cursor_combat"

/datum/preference/numeric/recoil_camera_strength
	db_key = "recoil_camera_strength"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "recoil_camera_strength"
	minimum = 0
	maximum = 100
	step = 10
