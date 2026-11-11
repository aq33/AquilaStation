/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { pingSuccess } from '../ping/actions';
import { connectionLost, connectionRestored, roundRestarted } from './actions';
import {
  AUTO_RECONNECT_AFTER,
  AUTO_RECONNECT_AFTER_LOST,
  AUTO_RECONNECT_GIVE_UP,
  AUTO_RECONNECT_INTERVAL,
  CONNECTION_LOST_AFTER,
} from './constants';
import { selectGame } from './selectors';

const withTimestamp = (action) => ({
  ...action,
  meta: {
    ...action.meta,
    now: Date.now(),
  },
});

export const gameMiddleware = (store) => {
  let lastPingedAt;
  let lastReconnectAt = 0;
  setInterval(() => {
    const state = store.getState();
    if (!state) {
      return;
    }
    const game = selectGame(state);
    const pingsAreFailing =
      lastPingedAt && Date.now() >= lastPingedAt + CONNECTION_LOST_AFTER;
    if (!game.connectionLostAt && pingsAreFailing) {
      store.dispatch(withTimestamp(connectionLost()));
    }
    if (game.connectionLostAt && !pingsAreFailing) {
      store.dispatch(withTimestamp(connectionRestored()));
    }
    const now = Date.now();
    // Liczone od restartu rundy, a bez komunikatu o nim od utraty połączenia
    const lostSince = game.roundRestartedAt || game.connectionLostAt;
    const reconnectAfter = game.roundRestartedAt
      ? AUTO_RECONNECT_AFTER
      : AUTO_RECONNECT_AFTER_LOST;
    if (
      lostSince &&
      game.connectionLostAt &&
      pingsAreFailing &&
      now >= lostSince + reconnectAfter &&
      now < lostSince + AUTO_RECONNECT_GIVE_UP &&
      now >= lastReconnectAt + AUTO_RECONNECT_INTERVAL
    ) {
      lastReconnectAt = now;
      Byond.command('.reconnect');
    }
  }, 1000);
  return (next) => (action) => {
    const { type, payload, meta } = action;
    if (type === pingSuccess.type) {
      lastPingedAt = meta.now;
      return next(action);
    }
    if (type === roundRestarted.type) {
      return next(withTimestamp(action));
    }
    return next(action);
  };
};
