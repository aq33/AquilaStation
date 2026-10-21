import { useAtom } from 'jotai';
import { Box, Button, Divider } from 'tgui-core/components';

import { tabAtom } from '.';
import { Tab } from './types';

export const lineHeightToc = '30.6px';

export function TableOfContents(props) {
  const [_tabIndex, setTabIndex] = useAtom(tabAtom);

  return (
    <Box textAlign="center">
      <Button lineHeight={lineHeightToc} fluid icon="pen" disabled>
        Wpisane imię
      </Button>

      <Button lineHeight={lineHeightToc} fluid icon="clipboard" disabled>
        Spis treści
      </Button>

      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="fire"
        onClick={() => setTabIndex(Tab.Defensive)}
      >
        Zabójcze inwokacje
      </Button>

      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="shield-alt"
        onClick={() => setTabIndex(Tab.Defensive)}
      >
        Inwokacje obronne
      </Button>
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="globe-americas"
        onClick={() => setTabIndex(Tab.Assistance)}
      >
        Magiczny transport
      </Button>
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="users"
        onClick={() => setTabIndex(Tab.Assistance)}
      >
        Wsparcie i przywołania
      </Button>
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="magic"
        onClick={() => setTabIndex(Tab.TableOfContents2)}
      >
        Rytuały
      </Button>
    </Box>
  );
}
