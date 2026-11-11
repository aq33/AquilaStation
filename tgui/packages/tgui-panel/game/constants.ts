/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const CONNECTION_LOST_AFTER = 15000;

// Dream Seeker 516 po zerwaniu próbuje połączyć się ponownie tylko raz (po 10 s), a nowy świat
// startuje dłużej. Wtedy łączy panel: po komunikacie o restarcie szybko, bez niego (crash serwera,
// zabity proces) dopiero po dłuższej ciszy, żeby nie łączyć ponownie gracza, który ma tylko lagi.
export const AUTO_RECONNECT_AFTER = 15000;
// Bez komunikatu o restarcie dopiero po 2 min ciszy: zawieszony, ale żywy serwer nie rozłącza graczy
export const AUTO_RECONNECT_AFTER_LOST = 120000;
export const AUTO_RECONNECT_INTERVAL = 20000;
// Dłużej nie ma sensu: serwer raczej nie wstanie sam
export const AUTO_RECONNECT_GIVE_UP = 15 * 60 * 1000;
