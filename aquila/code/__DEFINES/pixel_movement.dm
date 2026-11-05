// Ruch po pikselach (prototyp, aquila/code/datums/components/pixel_movement.dm). Stałe używane też w hookach core.

/// Mob z przesunięciem w kafelku (step_x/step_y) i bounding boxem 1x1. Wbudowane step()/walk() podaje mu wtedy w Move()
/// bieżący kafelek i nowe przesunięcie w pikselach zamiast sąsiedniego kafelka, a /atom/movable/Move() zamienia to na krok o kafelek.
#define TRAIT_PIXEL_MOVEMENT "pixel_movement"

/// Z /atom/movable/buckle_mob(), do przypinanego moba: (atom/movable/buckled_to)
#define COMSIG_LIVING_BUCKLED_TO "aq_living_buckled_to"
