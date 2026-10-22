// AQUILA - brakujące defines/helpery dla mutacji z Monkestation2.0

/// Postać nie zostawia odcisków palców (tg/Monke TRAIT_NO_FINGERPRINTS)
#ifndef TRAIT_NO_FINGERPRINTS
#define TRAIT_NO_FINGERPRINTS "no_fingerprints"
#endif

/// Źródło traitu prześwietlenia z przełączanego X-Raya
#define MONKE_XRAY_TOGGLE_TRAIT "monke_xray_toggle"

/// Odpowiednik tg SPT_PROB: szansa na zdarzenie w ciągu seconds sekund przy prob_per_second % na sekundę
#define MONKE_SPT_PROB(prob_per_second, seconds) (prob(100 * (1 - (1 - (prob_per_second) / 100) ** (seconds))))

/// Długość ticka Life u nas (SSmobs co 2 sekundy) - on_life() nie dostaje seconds_per_tick
#define MONKE_LIFE_SECONDS 2

/// Czas w dziesiątych sekundy na liczbę ticków Life (np. dizziness)
#define MONKE_TIME_TO_LIFE_TICKS(time) (CEILING((time) / (MONKE_LIFE_SECONDS SECONDS), 1))

/// Monke: uwuify_text (code/__HELPERS/uwuify.dm)
/proc/monke_uwuify_text(text)
	var/static/acreplace_setup = FALSE
	if(!acreplace_setup)
		rustg_setup_acreplace( \
			"monke_uwuify", \
			list( "ne",  "Ne",  "nE",  "NE",  "nu",  "Nu",  "nU",  "NU",  "na",  "Na",  "nA",  "NA",  "no",  "No",  "nO",  "NO", "ove", "Ove", "oVe", "OVe", "ovE", "OvE", "oVE", "OVE", "r", "R", "l", "L"), \
			list("nye", "Nye", "nYE", "NYE", "nyu", "Nyu", "nYU", "NYU", "nya", "Nya", "nYA", "NYA", "nyo", "Nyo", "nYO", "NYO",  "uv",  "Uv",  "uV",  "UV",  "uv",  "Uv",  "uV",  "UV", "w", "W", "w", "W") \
		)
		acreplace_setup = TRUE
	return rustg_acreplace("monke_uwuify", "[text]")

/// Niewidzialne odciski: odcisk dodany przez rodzica jest zdejmowany, włókna i ukryte odciski zostają
/datum/component/forensics/add_fingerprint(mob/living/M, ignoregloves = FALSE)
	if(!ishuman(M) || !HAS_TRAIT(M, TRAIT_NO_FINGERPRINTS))
		return ..()
	var/mob/living/carbon/human/H = M
	var/full_print = rustg_hash_string(RUSTG_HASH_MD5, H.dna.uni_identity)
	var/had_print = LAZYACCESS(fingerprints, full_print)
	. = ..()
	if(!had_print)
		LAZYREMOVE(fingerprints, full_print)
