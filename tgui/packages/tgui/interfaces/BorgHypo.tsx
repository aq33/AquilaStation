import {
  Button,
  Flex,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type BorgHypoContext = {
  maxVolume: number;
  theme: string;
  reagents: Reagent[];
  selectedReagent: string;
};

type Reagent = {
  name: string;
  volume: number;
  description: string;
};

export const BorgHypo = (props) => {
  const { data } = useBackend<BorgHypoContext>();
  const { maxVolume, theme, reagents = [], selectedReagent } = data;

  const dynamicHeight = reagents.length * 25 + 60;

  return (
    <Window width={400} height={dynamicHeight} theme={theme}>
      <Window.Content>
        <Section>
          <ReagentDisplay
            reagents={reagents}
            selected={selectedReagent}
            maxVolume={maxVolume}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};

type ReagentDisplayProps = {
  reagents: Reagent[];
  selected: string;
  maxVolume: number;
};

const ReagentDisplay = (props: ReagentDisplayProps) => {
  const { act } = useBackend();
  const { reagents, selected, maxVolume } = props;
  if (reagents.length === 0) {
    return <NoticeBox>Brak dostępnych odczynników!</NoticeBox>;
  }
  return reagents.map((reagent) => (
    <Flex key={reagent.name} m={0.5}>
      <Flex.Item grow>
        <ProgressBar value={reagent.volume / maxVolume}>
          <Flex>
            <Flex.Item grow textAlign="left">
              {reagent.name}
            </Flex.Item>
            <Flex.Item>{`${toFixed(reagent.volume)}u`}</Flex.Item>
          </Flex>
        </ProgressBar>
      </Flex.Item>
      <Flex.Item mx={1}>
        <Button
          icon="info-circle"
          textAlign="center"
          tooltip={reagent.description}
        />
      </Flex.Item>
      <Flex.Item textAlign="right">
        <Button
          icon="syringe"
          color={reagent.name === selected ? 'green' : 'default'}
          textAlign="center"
          onClick={() => act(reagent.name)}
        >
          Wybierz
        </Button>
      </Flex.Item>
    </Flex>
  ));
};
