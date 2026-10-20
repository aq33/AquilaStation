import {
  NoticeBox,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { ANTAG2COLOR } from './constants';
import { getAntagCategories } from './helpers';
import { OrbitCollapsible } from './OrbitCollapsible';
import type { AntagGroup, Observable, OrbitData } from './types';

type ContentSection = {
  content: Observable[];
  title: string;
  color?: string;
};

/**
 * The primary content display for points of interest.
 * Renders a scrollable section replete with collapsibles for each
 * observable group.
 */
export function OrbitContent(props) {
  const { act, data } = useBackend<OrbitData>();
  const { antagonists = [], critical = [] } = data;

  let antagGroups: AntagGroup[] = [];
  if (antagonists.length) {
    antagGroups = getAntagCategories(antagonists);
  }

  const sections: readonly ContentSection[] = [
    {
      color: 'purple',
      content: data.deadchat_controlled,
      title: 'Sterowane z deadchatu',
    },
    {
      color: 'blue',
      content: data.alive,
      title: 'Żywi',
    },
    {
      content: data.dead,
      title: 'Martwi',
    },
    {
      content: data.ghosts,
      title: 'Duchy',
    },
    {
      content: data.misc,
      title: 'Różne',
    },
    {
      content: data.npcs,
      title: 'NPC',
    },
  ];

  return (
    <Section fill scrollable>
      <Stack vertical>
        {critical.map((crit) => (
          <Tooltip content="Kliknij, żeby orbitować" key={crit.ref}>
            <NoticeBox
              verticalAlign
              color="purple"
              onClick={() => act('orbit', { ref: crit.ref })}
            >
              <Table>
                <Table.Row>
                  <Table.Cell>{toTitleCase(crit.full_name)}</Table.Cell>
                  <Table.Cell collapsing>{crit.extra}</Table.Cell>
                </Table.Row>
              </Table>
            </NoticeBox>
          </Tooltip>
        ))}

        {antagGroups.map(([title, members]) => (
          <OrbitCollapsible
            color={ANTAG2COLOR[title] || 'bad'}
            key={title}
            section={members}
            title={title}
          />
        ))}

        {sections.map((section) => (
          <OrbitCollapsible
            color={section.color}
            key={section.title}
            section={section.content}
            title={section.title}
          />
        ))}
      </Stack>
    </Section>
  );
}
