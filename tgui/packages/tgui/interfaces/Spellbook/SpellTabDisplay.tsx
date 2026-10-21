import {
  Box,
  Button,
  Divider,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { BUYWORD2ICON, BUYWORD2NAME } from './constants';
import {
  Buywords,
  type SpellbookData,
  SpellCategory,
  type SpellEntry,
} from './types';

type Props = {
  tabSpells: SpellEntry[];
  cooldownOffset?: number;
  pointOffset?: number;
};

function getTimeOrCat(entry: SpellEntry) {
  if (entry.cat === SpellCategory.Rituals) {
    if (entry.active) {
      return 'Już rzucone!';
    } else if (entry.times) {
      return `Rzucono ${entry.times} razy.`;
    } else {
      return 'Jeszcze nie rzucone.';
    }
  } else {
    if (entry.cooldown) {
      return `Odnowienie: ${entry.cooldown} s`;
    } else {
      return '';
    }
  }
}

export function SpellTabDisplay(props: Props) {
  const { act, data } = useBackend<SpellbookData>();
  const { points } = data;
  const { tabSpells, cooldownOffset, pointOffset } = props;

  return (
    <Stack vertical>
      {tabSpells
        .sort((a, b) => {
          return a.name.toLowerCase() < b.name.toLowerCase() ? -1 : 1;
        })
        .map((entry) => (
          <Stack.Item key={entry.ref}>
            <Divider />
            <Stack mt={1.3} width="100%" position="absolute" textAlign="left">
              <Stack.Item width="120px" ml={cooldownOffset}>
                {getTimeOrCat(entry)}
              </Stack.Item>
              <Stack.Item width="60px" ml={pointOffset}>
                {entry.cost ? `${entry.cost} pkt` : 'za darmo'}
              </Stack.Item>
              {entry.buyword === Buywords.Learn && (
                <Stack.Item>
                  <Button
                    mt={-0.8}
                    icon="tshirt"
                    color={entry.requires_wizard_garb ? 'bad' : 'green'}
                    tooltipPosition="bottom-start"
                    tooltip={
                      entry.requires_wizard_garb
                        ? 'Wymaga stroju czarodzieja.'
                        : 'Można rzucać bez stroju czarodzieja.'
                    }
                  />
                </Stack.Item>
              )}
            </Stack>
            <Section title={entry.name}>
              <Stack>
                <Stack.Item grow>
                  {entry.desc}
                  {entry.limit !== null && entry.limit !== undefined && (
                    <Box mt={0.5} color="label">
                      Pozostało: {entry.limit}
                    </Box>
                  )}
                </Stack.Item>
                <Stack.Item>
                  <Divider vertical />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    fluid
                    textAlign="center"
                    color={entry.can_buy ? 'green' : 'bad'}
                    disabled={!entry.can_buy || points < entry.cost}
                    width={7}
                    icon={BUYWORD2ICON[entry.buyword]}
                    onClick={() =>
                      act('purchase', {
                        spellref: entry.ref,
                      })
                    }
                  >
                    {BUYWORD2NAME[entry.buyword] || entry.buyword}
                  </Button>
                  <br />
                  {!entry.refundable ? (
                    <NoticeBox>Bez zwrotów.</NoticeBox>
                  ) : (
                    <Button
                      textAlign="center"
                      width={7}
                      icon="arrow-left"
                      disabled={!entry.can_refund}
                      onClick={() =>
                        act('refund', {
                          spellref: entry.ref,
                        })
                      }
                    >
                      Zwróć
                    </Button>
                  )}
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        ))}
    </Stack>
  );
}
