import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Divider,
  Flex,
  Icon,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Hint = {
  icon: string;
  desc: string;
};

type Availability = {
  icon: string;
  color: string;
};

type TooltipStats = {
  weight: number;
  conductivity: number;
  alt_name: string | null;
  desc: string;
  hints: Hint[];
  availability: Availability[];
};

type Data = {
  activator_traits: string[];
  minor_traits: string[];
  major_traits: string[];
  malfunction_list: string[];
  tooltip_stats: Record<string, TooltipStats>;
  trait_filters: Hint[];
  selected_traits: string[];
  deselected_traits: string[];
  enabled_trait_filters: string[];
  filtered_traits: string[];
};

export const XenoartifactLabeler = (props) => {
  return (
    <Window width={500} height={600}>
      <Window.Content>
        <Section>
          <Flex>
            <Flex.Item>
              <XenoartifactlabelerSticker />
            </Flex.Item>
            <Flex.Item ml="auto">
              <Button
                icon="question"
                tooltip="Lewy przycisk zaznacza cechę, prawy ją wyklucza."
              />
            </Flex.Item>
          </Flex>
        </Section>
        <Divider />
        <Section>
          <Collapsible title="Filtry">
            <XenoartifactlabelerGenerateFilterEntry />
          </Collapsible>
        </Section>
        <Divider />
        <Flex direction="row">
          <Flex.Item>
            <XenoartifactlabelerTraits />
          </Flex.Item>
          <Flex.Item grow>
            <XenoartifactlabelerInfo />
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const alphasort = (a: string, b: string) => a.localeCompare(b, 'pl');

const TraitSection = (props: {
  title: string;
  traits: string[];
  filtered: string[];
}) => {
  const { title, traits, filtered } = props;
  const shown = [...(traits || [])]
    .sort(alphasort)
    .filter((trait) => !filtered.includes(trait));
  return (
    <Section title={title}>
      <Box>
        {shown.map((trait) => (
          <XenoartifactlabelerGenerateEntry
            specific_trait={trait}
            key={trait}
          />
        ))}
      </Box>
    </Section>
  );
};

const XenoartifactlabelerTraits = (props) => {
  const { data } = useBackend<Data>();
  const {
    activator_traits,
    minor_traits,
    major_traits,
    malfunction_list,
    filtered_traits = [],
  } = data;
  return (
    <Box px={1} overflowY="scroll" height="72vh" width="170px">
      <TraitSection
        title="Aktywatory"
        traits={activator_traits}
        filtered={filtered_traits}
      />
      <Divider />
      <TraitSection
        title="Cechy pomniejsze"
        traits={minor_traits}
        filtered={filtered_traits}
      />
      <Divider />
      <TraitSection
        title="Cechy główne"
        traits={major_traits}
        filtered={filtered_traits}
      />
      <Divider />
      <TraitSection
        title="Usterki"
        traits={malfunction_list}
        filtered={filtered_traits}
      />
    </Box>
  );
};

const XenoartifactlabelerInfo = (props) => {
  const { data } = useBackend<Data>();
  const { selected_traits = [] } = data;
  return (
    <Box px={1} overflowY="auto" height="72vh">
      {selected_traits.map((info) => (
        <XenoartifactlabelerGenerateInfo info={info} key={info} />
      ))}
    </Box>
  );
};

const XenoartifactlabelerGenerateEntry = (props: {
  specific_trait: string;
}) => {
  const { act, data } = useBackend<Data>();
  const { specific_trait } = props;
  const { tooltip_stats, selected_traits = [], deselected_traits = [] } = data;
  const stats = tooltip_stats[specific_trait];
  const tooltip = stats
    ? `${stats.alt_name ? `${stats.alt_name}, ` : ''}Waga: ${stats.weight}, Przewodność: ${stats.conductivity}`
    : undefined;
  return (
    <Box>
      <Button.Checkbox
        checked={selected_traits.includes(specific_trait)}
        color={
          deselected_traits.includes(specific_trait) ? 'bad' : 'transparent'
        }
        tooltip={tooltip}
        onClick={() =>
          act('toggle_trait', { trait_name: specific_trait, select: true })
        }
        onContextMenu={(e) => {
          e.preventDefault();
          act('toggle_trait', { trait_name: specific_trait, select: false });
        }}
      >
        {specific_trait}
      </Button.Checkbox>
    </Box>
  );
};

const XenoartifactlabelerGenerateInfo = (props: { info: string }) => {
  const { data } = useBackend<Data>();
  const { info } = props;
  const stats = data.tooltip_stats[info];
  if (!stats) {
    return null;
  }
  return (
    <Section title={info}>
      <Box italic>
        <BlockQuote>{stats.desc}</BlockQuote>
        {stats.hints.map((hint) => (
          <Button icon={hint.icon} tooltip={hint.desc} key={hint.desc} />
        ))}
        {stats.availability.map((material, index) => (
          <Icon name={material.icon} color={material.color} key={index} />
        ))}
      </Box>
    </Section>
  );
};

const XenoartifactlabelerSticker = (props) => {
  const { act } = useBackend<Data>();
  return (
    <Box>
      <Button onClick={() => act('print_traits')}>Drukuj</Button>
      <Button onClick={() => act('clear_traits')}>Wyczyść</Button>
    </Box>
  );
};

const XenoartifactlabelerGenerateFilterEntry = (props) => {
  const { act, data } = useBackend<Data>();
  const { trait_filters = [], enabled_trait_filters = [] } = data;
  return (
    <Box>
      {trait_filters.map((filter) => (
        <Button
          key={filter.icon}
          tooltip={filter.desc}
          icon={filter.icon}
          selected={enabled_trait_filters.includes(filter.icon)}
          onClick={() => act('toggle_filter', { filter: filter.icon })}
        />
      ))}
    </Box>
  );
};
