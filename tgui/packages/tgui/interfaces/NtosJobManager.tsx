import {
  Box,
  Button,
  Dimmer,
  NoticeBox,
  Section,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Slot = {
  title: string;
  current: number;
  total: number;
  status_open: BooleanLike;
  status_close: BooleanLike;
};

type Data = {
  authed: BooleanLike;
  cooldown: number;
  prioritized: string[];
  slots: Slot[];
};

export const NtosJobManager = (props) => {
  return (
    <NtosWindow width={400} height={620}>
      <NtosWindow.Content scrollable>
        <NtosJobManagerContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosJobManagerContent = (props) => {
  const { act, data } = useBackend<Data>();

  const { authed, cooldown, slots = [], prioritized = [] } = data;

  if (!authed) {
    return (
      <NoticeBox>
        To ID nie ma uprawnień do zmiany liczby miejsc pracy.
      </NoticeBox>
    );
  }

  return (
    <Section>
      {cooldown > 0 && (
        <Dimmer>
          <Box bold textAlign="center" fontSize="20px">
            Odczekaj: {cooldown} s
          </Box>
        </Dimmer>
      )}
      <Table>
        <Table.Row header>
          <Table.Cell>Priorytet</Table.Cell>
          <Table.Cell>Miejsca</Table.Cell>
        </Table.Row>
        {slots.map((slot) => (
          <Table.Row key={slot.title} className="candystripe">
            <Table.Cell bold>
              <Button.Checkbox
                fluid
                content={slot.title}
                disabled={slot.total <= 0}
                checked={slot.total > 0 && prioritized.includes(slot.title)}
                onClick={() =>
                  act('PRG_priority', {
                    target: slot.title,
                  })
                }
              />
            </Table.Cell>
            <Table.Cell collapsing>
              {slot.current} / {slot.total}
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                content="Otwórz"
                disabled={!slot.status_open}
                onClick={() =>
                  act('PRG_open_job', {
                    target: slot.title,
                  })
                }
              />
              <Button
                content="Zamknij"
                disabled={!slot.status_close}
                onClick={() =>
                  act('PRG_close_job', {
                    target: slot.title,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
