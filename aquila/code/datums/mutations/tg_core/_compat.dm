// AQUILA - brakujące defines/helpery dla mutacji z tgstation wymagających systemów rdzenia (tg_core)

// --- Traity (nazwy jak w tg) ---

/// Grube palce: nie mieszczą się w kabłąku spustu (tg TRAIT_CHUNKYFINGERS)
#ifndef TRAIT_CHUNKYFINGERS
#define TRAIT_CHUNKYFINGERS "chunkyfingers"
#endif

/// Nie może trzymać przedmiotów oburącz (tg TRAIT_NO_TWOHANDING)
#ifndef TRAIT_NO_TWOHANDING
#define TRAIT_NO_TWOHANDING "no_twohanding"
#endif

/// Może jeść rudy i minerały (tg TRAIT_ROCK_EATER)
#ifndef TRAIT_ROCK_EATER
#define TRAIT_ROCK_EATER "rock_eater"
#endif

/// Zjedzone minerały dają efekty (tg TRAIT_ROCK_METAMORPHIC)
#ifndef TRAIT_ROCK_METAMORPHIC
#define TRAIT_ROCK_METAMORPHIC "rock_metamorphic"
#endif

/// Bardzo wysoki (tg TRAIT_TOO_TALL, u nas tylko z akromegalii)
#ifndef TRAIT_TOO_TALL
#define TRAIT_TOO_TALL "too_tall"
#endif

#ifndef TRAIT_STATUS_EFFECT
#define TRAIT_STATUS_EFFECT(effect_id) "[effect_id]-trait"
#endif

// --- Sygnały (nazwy jak w tg) ---

/// Z /mob/living/put_in_hand_check(): (obj/item/I)
#ifndef COMSIG_LIVING_TRY_PUT_IN_HAND
#define COMSIG_LIVING_TRY_PUT_IN_HAND "living_try_put_in_hand"
	#define COMPONENT_LIVING_CANT_PUT_IN_HAND (1<<0)
#endif

/// Z /mob/living/start_pulling(): (atom/movable/target, force)
#ifndef COMSIG_LIVING_TRY_PULL
#define COMSIG_LIVING_TRY_PULL "living_try_pull"
	#define COMSIG_LIVING_CANCEL_PULL (1<<0)
#endif

/// Przy próbie przyczepienia kończyny do węglowca: (obj/item/bodypart/new_limb, special)
#ifndef COMSIG_ATTEMPT_CARBON_ATTACH_LIMB
#define COMSIG_ATTEMPT_CARBON_ATTACH_LIMB "attempt_carbon_attach_limb"
	#define COMPONENT_NO_ATTACH (1<<0)
#endif

// --- Kolory światła z tg, których u nas brakuje ---

#ifndef LIGHT_COLOR_DEFAULT
#define LIGHT_COLOR_DEFAULT "#f3fffa"
#endif
#ifndef LIGHT_COLOR_FAINT_BLUE
#define LIGHT_COLOR_FAINT_BLUE "#DEEFFF"
#endif
#ifndef LIGHT_COLOR_DIM_YELLOW
#define LIGHT_COLOR_DIM_YELLOW "#E1E17D"
#endif
#ifndef LIGHT_COLOR_ELECTRIC_CYAN
#define LIGHT_COLOR_ELECTRIC_CYAN "#00FFFF"
#endif
#ifndef LIGHT_COLOR_BRIGHT_YELLOW
#define LIGHT_COLOR_BRIGHT_YELLOW "#FFFF99"
#endif
#ifndef COLOR_HEALING_CYAN
#define COLOR_HEALING_CYAN "#80F5FF"
#endif
#ifndef COLOR_BRIGHT_BLUE
#define COLOR_BRIGHT_BLUE "#2CB2E8"
#endif

/// tg is_path_in_list: czy ścieżka jest podtypem którejś ze ścieżek w liście
/proc/tg_core_path_in_list(path, list/paths)
	if(!ispath(path))
		return FALSE
	for(var/checked in paths)
		if(ispath(path, checked))
			return TRUE
	return FALSE
