/**
 * AQUILA: KeyListener from tgui-core listens to the hotkeys of tgui-core,
 * which are never set up here (index.tsx starts our own events and hotkeys),
 * so it never got a key. This one listens to our hotkeys instead.
 */
import { useEffect } from 'react';

import type { KeyEvent } from '../events';
import { listenForKeyEvents } from '../hotkeys';

type KeyListenerProps = Partial<{
  onKey: (key: KeyEvent) => void;
  onKeyDown: (key: KeyEvent) => void;
  onKeyUp: (key: KeyEvent) => void;
}>;

export function KeyListener(props: KeyListenerProps) {
  const { onKey, onKeyDown, onKeyUp } = props;

  useEffect(() => {
    const unsubscribe = listenForKeyEvents((key) => {
      onKey?.(key);
      if (key.isDown()) {
        onKeyDown?.(key);
      }
      if (key.isUp()) {
        onKeyUp?.(key);
      }
    });
    return unsubscribe;
  }, [onKey, onKeyDown, onKeyUp]);

  return null;
}
