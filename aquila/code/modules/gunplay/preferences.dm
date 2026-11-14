// AQUILA - ustawienia graczy do reworku strzelania (okno: tgui/.../game_preferences/gunplay.tsx)

/datum/preferences
	/// Kursor pokazujący rozrzut trzymanej broni (domyślnie wyłączony: gracze zgłaszali lag przy ruchu myszy z bronią)
	var/gun_cursor = FALSE
	/// Postać w combat mode patrzy na kursor, także w ruchu (domyślnie wyłączone, jak wyżej)
	var/face_cursor_combat = FALSE
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

/// Jednorazowe wyłączenie kursora rozrzutu i patrzenia na kursor także graczom z zapisanymi preferencjami.
/// Nazwa migracji trafia do keybind_migrations (lista jednorazowych migracji zapisywana w bazie), więc
/// gracz, który potem sam włączy opcje, zostaje przy swoim wyborze.
#define AQ_GUN_CURSOR_OFF_MIGRATION "gun_cursor_off_2026_11"

/datum/preferences/load_from_database()
	. = ..()
	aq_migrate_gun_cursor_off()

/// TRUE, gdy migracja właśnie przeszła (opcje wyłączone)
/datum/preferences/proc/aq_migrate_gun_cursor_off()
	if(!islist(keybind_migrations))
		keybind_migrations = list()
	if(AQ_GUN_CURSOR_OFF_MIGRATION in keybind_migrations)
		return FALSE
	keybind_migrations += AQ_GUN_CURSOR_OFF_MIGRATION
	gun_cursor = FALSE
	face_cursor_combat = FALSE
	return TRUE

#undef AQ_GUN_CURSOR_OFF_MIGRATION
