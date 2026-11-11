// NSV13
// AQUILA: program na tablecie korzysta z tego samego okna co konsola (bez kamery pancerza).

import { NtosWindow } from '../layouts';
import { SquadConsoleContent } from './SquadManager';

export const NtosSquadManager = () => {
  return (
    <NtosWindow width={1280} height={820}>
      <NtosWindow.Content>
        <SquadConsoleContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
