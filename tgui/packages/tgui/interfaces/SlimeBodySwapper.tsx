import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Body = {
  htmlcolor: string;
  area: string;
  status: string;
  exoticblood: number;
  name: string;
  ref: string;
  occupied: string;
};

type Data = {
  bodies: Body[];
};

const statusMap = {
  Dead: 'bad',
  Unconscious: 'average',
  Conscious: 'good',
};

// Wartości status przychodzą z DM po angielsku, tu tylko je wyświetlamy po polsku
const statusNames = {
  Dead: 'Martwe',
  Unconscious: 'Nieprzytomne',
  Conscious: 'Przytomne',
};

const occupiedMap = {
  owner: 'Tu jesteś',
  stranger: 'Zajęte',
  available: 'Przenieś się',
};

export const BodyEntry = (props: { body: Body; swapFunc: () => void }) => {
  const { body, swapFunc } = props;
  return (
    <Section
      title={
        <Box inline color={body.htmlcolor}>
          {body.name}
        </Box>
      }
      buttons={
        <Button
          selected={body.occupied === 'owner'}
          color={body.occupied === 'stranger' ? 'bad' : undefined}
          onClick={() => swapFunc()}
        >
          {occupiedMap[body.occupied]}
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Stan" color={statusMap[body.status]}>
          <Box bold>{statusNames[body.status] || body.status}</Box>
        </LabeledList.Item>
        <LabeledList.Item label="Galareta">{body.exoticblood}</LabeledList.Item>
        <LabeledList.Item label="Położenie">{body.area}</LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const SlimeBodySwapper = (props) => {
  const { act, data } = useBackend<Data>();
  const { bodies = [] } = data;
  return (
    <Window width={400} height={400}>
      <Window.Content scrollable>
        <Section>
          {bodies.map((body) => (
            <BodyEntry
              key={body.name}
              body={body}
              swapFunc={() => act('swap', { ref: body.ref })}
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
