import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  connected: BooleanLike;
  notice: string;
  target: string;
  unlocked: BooleanLike;
};

export const BluespaceArtillery = (props) => {
  const { act, data } = useBackend<Data>();
  const { notice, connected, unlocked, target } = data;
  return (
    <Window width={400} height={220}>
      <Window.Content>
        {!!notice && <NoticeBox>{notice}</NoticeBox>}
        {connected ? (
          <>
            <Section
              title="Cel"
              buttons={
                <Button
                  icon="crosshairs"
                  disabled={!unlocked}
                  tooltip="Przekalibruj cel"
                  onClick={() => act('recalibrate')}
                />
              }
            >
              <Box color={target ? 'average' : 'bad'} fontSize="25px">
                {target || 'Nie ustawiono celu'}
              </Box>
            </Section>
            <Section>
              {unlocked ? (
                <Box style={{ margin: 'auto' }}>
                  <Button
                    fluid
                    content="OGNIA"
                    color="bad"
                    disabled={!target}
                    fontSize="30px"
                    textAlign="center"
                    lineHeight="46px"
                    onClick={() => act('fire')}
                  />
                </Box>
              ) : (
                <>
                  <Box color="bad" fontSize="18px">
                    Artyleria bluespace jest zablokowana.
                  </Box>
                  <Box mt={1}>
                    Oczekiwanie na autoryzację w czytniku kart od co najmniej
                    dwóch szefów stacji.
                  </Box>
                </>
              )}
            </Section>
          </>
        ) : (
          <Section>
            <LabeledList>
              <LabeledList.Item label="Konserwacja">
                <Button
                  icon="wrench"
                  content="Zakończ montaż"
                  onClick={() => act('build')}
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
