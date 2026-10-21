import { Button, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type BorgShakerContext = {
  minVolume: number;
  theme: string;
  sodas: Reagent[];
  alcohols: Reagent[];
  selectedReagent: string;
};

type Reagent = {
  name: string;
  volume: number;
};

export const BorgShaker = (props) => {
  const { data } = useBackend<BorgShakerContext>();
  const { theme, minVolume, sodas = [], alcohols = [], selectedReagent } = data;

  const dynamicHeight =
    Math.ceil(sodas.length / 4) * 23 +
    Math.ceil(alcohols.length / 4) * 23 +
    140;

  return (
    <Window width={650} height={dynamicHeight} theme={theme}>
      <Window.Content>
        <Section title="Bezalkoholowe">
          <ReagentDisplay
            reagents={sodas}
            selected={selectedReagent}
            minimum={minVolume}
          />
        </Section>
        <Section title="Alkoholowe">
          <ReagentDisplay
            reagents={alcohols}
            selected={selectedReagent}
            minimum={minVolume}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};

type ReagentDisplayProps = {
  reagents: Reagent[];
  selected: string;
  minimum: number;
};

const ReagentDisplay = (props: ReagentDisplayProps) => {
  const { act } = useBackend();
  const { reagents, selected, minimum } = props;
  if (reagents.length === 0) {
    return <NoticeBox>Brak dostępnych odczynników!</NoticeBox>;
  }
  return reagents.map((reagent) => (
    <Button
      key={reagent.name}
      icon="tint"
      width="150px"
      lineHeight={1.75}
      color={reagent.name === selected ? 'green' : 'default'}
      disabled={reagent.volume < minimum}
      onClick={() => act(reagent.name)}
    >
      {reagent.name}
    </Button>
  ));
};
