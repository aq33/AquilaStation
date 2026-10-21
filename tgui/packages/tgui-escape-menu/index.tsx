import './styles/main.scss';

import { createRoot, type Root } from 'react-dom/client';

import { loadMappings, loadStyleSheet } from './assets';
import { EscapeMenu, isResizeFrozen, receiveMessage } from './EscapeMenu';
import { updateScaling } from './scaling';

let reactRoot: Root | null = null;

document.onreadystatechange = () => {
  if (document.readyState !== 'complete') return;

  updateScaling();

  window.addEventListener('resize', () => {
    if (isResizeFrozen()) return;
    updateScaling();
  });

  // Jeden słuchacz na wszystko: pierwszy Byond.subscribe dostaje całą kolejkę
  // wiadomości sprzed startu, więc nic nie może przepaść między kilkoma subskrypcjami.
  Byond.subscribe((type: string, payload: any) => {
    if (type === 'asset/stylesheet') {
      loadStyleSheet(payload);
      return;
    }
    if (type === 'asset/mappings') {
      loadMappings(payload);
      return;
    }
    receiveMessage(type, payload);
  });

  if (!reactRoot) {
    const root = document.getElementById('react-root');
    reactRoot = createRoot(root!);
  }

  reactRoot.render(<EscapeMenu />);
};
