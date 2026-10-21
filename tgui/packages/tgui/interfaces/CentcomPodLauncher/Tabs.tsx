import { Box, Button } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { PodLauncherData } from './types';

export function TabPod(props) {
  return (
    <Box color="label">
      Uwaga: tę wzorcową kapsułę możesz kliknąć
      <br />
      prawym przyciskiem i edytować jej zmienne
    </Box>
  );
}

export function TabBay(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { oldArea } = data;

  return (
    <>
      <Button icon="street-view" onClick={() => act('teleportCentcom')}>
        Teleportuj
      </Button>
      <Button
        disabled={!oldArea}
        icon="undo-alt"
        onClick={() => act('teleportBack')}
      >
        {oldArea ? oldArea.substring(0, 17) : 'Wróć'}
      </Button>
    </>
  );
}

export function TabDrop(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { oldArea } = data;

  return (
    <>
      <Button icon="street-view" onClick={() => act('teleportDropoff')}>
        Teleportuj
      </Button>
      <Button
        disabled={!oldArea}
        icon="undo-alt"
        onClick={() => act('teleportBack')}
      >
        {oldArea ? oldArea.substring(0, 17) : 'Wróć'}
      </Button>
    </>
  );
}
