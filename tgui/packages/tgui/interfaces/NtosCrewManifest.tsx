import { map } from 'es-toolkit/compat';
import { Button, Section, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type ManifestEntry = {
  name: string;
  rank: string;
};

type Data = {
  have_printer: BooleanLike;
  manifest: Record<string, ManifestEntry[]>;
};

export const NtosCrewManifest = (props) => {
  const { act, data } = useBackend<Data>();
  const { have_printer, manifest = {} } = data;

  return (
    <NtosWindow width={400} height={480}>
      <NtosWindow.Content scrollable>
        <Section
          title="Manifest załogi"
          buttons={
            <Button
              icon="print"
              disabled={!have_printer}
              tooltip={have_printer ? undefined : 'Brak drukarki'}
              onClick={() => act('PRG_print')}
            >
              Drukuj
            </Button>
          }
        >
          {map(manifest, (entries, department) => (
            <Section key={department} title={department}>
              <Table>
                {entries.map((entry) => (
                  <Table.Row key={entry.name} className="candystripe">
                    <Table.Cell bold>{entry.name}</Table.Cell>
                    <Table.Cell>({entry.rank})</Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          ))}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
