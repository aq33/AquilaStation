import { useState } from 'react';
import { Button, Modal } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { TechwebContent } from './Content';
import { TechWebRoute } from './hooks';
import type { TechWebData } from './types';

export function TechwebStart(props) {
  const { act, data } = useBackend<TechWebData>();
  const { locked } = data;
  const techwebState = useState({
    route: '',
  });

  if (locked) {
    return (
      <Modal width="15em" align="center" className="Techweb__LockedModal">
        <div>
          <b>Konsola zablokowana</b>
        </div>
        <Button icon="unlock" onClick={() => act('toggleLock')}>
          Odblokuj
        </Button>
      </Modal>
    );
  }

  return (
    <TechWebRoute.Provider value={techwebState}>
      <TechwebContent />
    </TechWebRoute.Provider>
  );
}
