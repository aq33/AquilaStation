// Z-Mimic: piętro niżej widziane przez otwartą przestrzeń (port BeeStation/BeeStation-Hornet#8813 z poprawkami
// z BeeStation/BeeStation-Hornet#14823; pierwotnie DaedalusDock/daedalusdock#280, Baystation/Nebula).
// Opis działania: aquila/code/modules/multiz/zmimic/documentation.md

// Plany kopii z piętra niżej: od ZMIMIC_MAX_PLANE w dół o głębokość, pod podłogą i nad parallaksą kosmosu
/// Najwyższy plan kopii, zajmuje ZMIMIC_MAX_PLANE - ZMIMIC_MAX_DEPTH .. ZMIMIC_MAX_PLANE
#define ZMIMIC_MAX_PLANE -70
/// Głębokość, od której wszystko trafia na ten sam plan
#define ZMIMIC_MAX_DEPTH 10
/// Plan cienia i światła piętra niżej. Jego plane master mnoży się na wszystkie plany kopii pod nim.
/// U Bee każda głębokość ma swój plan cienia z przekaźnikiem; u nas plane mastery nie mają przekaźników, więc jeden wspólny.
#define ZMIMIC_SHADOW_PLANE -68
/// Plan cieni pięter głębszych niż jedno (kopie shadowerów z niższych otwartych przestrzeni), mnożony przed ZMIMIC_SHADOW_PLANE
#define ZMIMIC_DEEP_SHADOW_PLANE -69
/// Warstwa kopii światła na planie cienia
#define MIMICKED_LIGHTING_LAYER 5.06

#define FIRE_PRIORITY_ZCOPY 10
/// Po świetle i większości obiektów
#define INIT_ORDER_ZCOPY -22

#define TURF_IS_MIMICKING(T) (isturf(T) && (T:z_flags & Z_MIMIC_BELOW))

#define CHECK_OO_EXISTENCE(OO) if (OO && !MOVABLE_IS_ON_ZTURF(OO) && !OO:destruction_timer) { OO:destruction_timer = QDEL_IN(OO, 10 SECONDS); }
#define UPDATE_OO_IF_PRESENT CHECK_OO_EXISTENCE(src:bound_overlay); if (src:bound_overlay) { update_above(); }

// These aren't intended to be used anywhere else, they just can't be undef'd because DM is dum.
#define ZM_INTERNAL_SCAN_LOOKAHEAD(M,VTR,F) ((get_step(M, M:dir)?:VTR & F) || (get_step(M, turn(M:dir, 180))?:VTR & F))
#define ZM_INTERNAL_SCAN_LOOKBESIDE(M,VTR,F) ((get_step(M, turn(M:dir, 90))?:VTR & F) || (get_step(M, turn(M:dir, -90))?:VTR & F))

/// Is this movable visible from a turf that is mimicking below? Note: this does not necessarily mean *directly* below.
#define MOVABLE_IS_BELOW_ZTURF(M) (\
	isturf(M:loc) && (TURF_IS_MIMICKING(M:loc:above) \
	|| ((M:zmm_flags & ZMM_LOOKAHEAD) && ZM_INTERNAL_SCAN_LOOKAHEAD(M, above?:z_flags, Z_MIMIC_BELOW))  \
	|| ((M:zmm_flags & ZMM_LOOKBESIDE) && ZM_INTERNAL_SCAN_LOOKBESIDE(M, above?:z_flags, Z_MIMIC_BELOW))) \
)
/// Is this movable located on a turf that is mimicking below? Note: this does not necessarily mean *directly* on.
#define MOVABLE_IS_ON_ZTURF(M) (\
	isturf(M:loc) && (TURF_IS_MIMICKING(M:loc) \
	|| ((M:zmm_flags & ZMM_LOOKAHEAD) && ZM_INTERNAL_SCAN_LOOKAHEAD(M, z_flags, Z_MIMIC_BELOW)) \
	|| ((M:zmm_flags & ZMM_LOOKBESIDE) && ZM_INTERNAL_SCAN_LOOKBESIDE(M, z_flags, Z_MIMIC_BELOW))) \
)

// Turf Z-Mimic flags (/turf/var/z_flags). Ruch między piętrami zostaje u nas na obj_flags (BLOCK_Z_*).

#define Z_MIMIC_BELOW      (1 << 4)	//! Should this turf mimic the below turf?
#define Z_MIMIC_OVERWRITE  (1 << 5)	//! If this turf is mimicking, overwrite its appearance instead of using a mimic object. This is faster, but means the turf cannot have its own appearance.
#define Z_MIMIC_NO_OCCLUDE (1 << 6)	//! If we're a non-OVERWRITE z-turf, allow clickthrough of this turf.
#define Z_MIMIC_BASETURF   (1 << 7)	//! Fake-copy baseturf instead of below turf.

GLOBAL_LIST_INIT(z_defines, list(
	"Z_MIMIC_BELOW",
	"Z_MIMIC_OVERWRITE",
	"Z_MIMIC_NO_OCCLUDE",
	"Z_MIMIC_BASETURF"
))

// Z-Mimic movable flags. This is not prefixed with ZM_* to avoid confusion with other codebases that use that prefix for the above flags.

#define ZMM_IGNORE          (1 << 0)	//! Do not copy this movable. Atoms with INVISIBILITY_ABSTRACT implicitly do not copy.
#define ZMM_LOOKAHEAD       (1 << 2)	//! Look one turf ahead and one turf back when considering z-turfs that might be seeing this atom. Respects dir. Cheap, but not free.
#define ZMM_LOOKBESIDE      (1 << 3)	//! Look one turf to the left and right when considering z-turfs that might be seeing this atom. Respects dir. Cheap, but not free.
#define ZMM_NO_CACHE_ROOT   (1 << 5)	//! When performing mangling, do not cache the root (depth=0) appearance. Set this on mangled types that change appearance frequently.

/// Atom is big and needs to scan one extra turf in both X and Y. This only extends the range by one turf. Cheap, but not free.
#define ZMM_WIDE_LOAD (ZMM_LOOKAHEAD | ZMM_LOOKBESIDE)

#define GET_TURF_DEPTH(turf) (!isnull((turf).z_depth) ? (turf).z_depth : (turf).calculate_zdepth())

#define ZMIMIC_DEPTH(turf_depth) min(ZMIMIC_MAX_DEPTH - (turf_depth), ZMIMIC_MAX_DEPTH)

/// Rozmycie piętra niżej jak w tg (tgstation/tgstation#69115: blur 0.75)
#define ZMIMIC_BLUR_SIZE 0.75
/// Przyciemnienie piętra niżej (mnożnik kolorów na planach kopii)
#define ZMIMIC_DARKENING_FACTOR 0.8
