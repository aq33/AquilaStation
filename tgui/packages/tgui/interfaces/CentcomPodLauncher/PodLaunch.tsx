import { Box, Button } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { useCompact } from './hooks';
import type { PodLauncherData } from './types';

export function PodLaunch(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { giveLauncher } = data;

  const [compact] = useCompact();

  return (
    <Button
      fluid
      onClick={() => act('giveLauncher')}
      selected={giveLauncher}
      textAlign="center"
      tooltip={`
        Wiesz chyba, co Codex
        Astartes mówi na ten temat`}
      tooltipPosition="top"
    >
      <Box bold fontSize="1.4em" lineHeight={compact ? 1.5 : 3}>
        ODPAL
      </Box>
    </Button>
  );
}
