import { NoticeBox } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { LaunchpadControl } from './LaunchpadConsole';

type Data = {
  has_pad: BooleanLike;
  pad_closed: BooleanLike;
};

export const LaunchpadRemote = (props) => {
  const { data } = useBackend<Data>();
  const { has_pad, pad_closed } = data;

  return (
    <Window
      title="Pilot wyrzutni w walizce"
      width={340}
      height={275}
      theme="syndicate"
    >
      <Window.Content>
        {(!has_pad && <NoticeBox>Brak podłączonej wyrzutni</NoticeBox>) ||
          (pad_closed && <NoticeBox>Wyrzutnia zamknięta</NoticeBox>) || (
            <LaunchpadControl topLevel />
          )}
      </Window.Content>
    </Window>
  );
};
