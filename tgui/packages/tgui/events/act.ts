/**
 * tgstation keeps `sendAct` in tgui/events/act. Our backend still lives in
 * backend.ts, so windows ported from tg import it through this module.
 */
export { sendAct } from '../backend';
