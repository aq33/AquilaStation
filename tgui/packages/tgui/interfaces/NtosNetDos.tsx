import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  capacity: number;
  error: string;
  focus: string;
  overload: number;
  relays: { id: string }[];
  speed: number;
  target: boolean;
};

export const NtosNetDos = (props) => {
  return (
    <NtosWindow theme="syndicate" width={400} height={250}>
      <NtosWindow.Content>
        <NtosNetDosContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosNetDosContent = (props) => {
  const { act, data } = useBackend<Data>();

  const { relays = [], focus, target, speed, overload, capacity, error } = data;

  if (error) {
    return (
      <>
        <NoticeBox>{error}</NoticeBox>
        <Button
          fluid
          content="Resetuj"
          textAlign="center"
          onClick={() => act('PRG_reset')}
        />
      </>
    );
  }

  const generate10String = (length) => {
    let outString = '';
    const factor = overload / capacity;
    while (outString.length < length) {
      if (Math.random() > factor) {
        outString += '0';
      } else {
        outString += '1';
      }
    }
    return outString;
  };

  const lineLength = 45;

  if (target) {
    return (
      <Section fontFamily="monospace" textAlign="center">
        <Box>AKTUALNA PRĘDKOŚĆ: {speed} GQ/s</Box>
        <Box>
          {/* I don't care anymore */}
          {generate10String(lineLength)}
        </Box>
        <Box>{generate10String(lineLength)}</Box>
        <Box>{generate10String(lineLength)}</Box>
        <Box>{generate10String(lineLength)}</Box>
        <Box>{generate10String(lineLength)}</Box>
      </Section>
    );
  }

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Cel">
          {relays.map((relay) => (
            <Button
              key={relay.id}
              content={relay.id}
              selected={focus === relay.id}
              onClick={() =>
                act('PRG_target_relay', {
                  targid: relay.id,
                })
              }
            />
          ))}
        </LabeledList.Item>
      </LabeledList>
      <Button
        fluid
        bold
        content="WYKONAJ"
        color="bad"
        textAlign="center"
        disabled={!focus}
        mt={1}
        onClick={() => act('PRG_execute')}
      />
    </Section>
  );
};
