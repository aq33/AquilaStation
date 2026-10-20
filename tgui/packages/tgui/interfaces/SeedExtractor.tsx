import { sortBy } from 'es-toolkit';
import { Button, Section, Table } from 'tgui-core/components';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// tg's window is built on SeedTable with plant traits and scrapping, which our
// extractor does not have. Ours keys seed piles by a "name=...;lifespan=..."
// string and only vends them.

type Data = {
  /** Seed string -> number of packs in that pile. */
  seeds: Record<string, number>;
};

type Seed = {
  key: string;
  amount: number;
  name: string;
  lifespan?: string;
  endurance?: string;
  maturation?: string;
  production?: string;
  yield?: string;
  potency?: string;
};

/**
 * This method takes a seed string and splits the values
 * into an object
 */
const splitSeedString = (text: string) => {
  const re = /([^;=]+)=([^;]+)/g;
  const ret: Record<string, string> = {};
  let m: RegExpExecArray | null;
  do {
    m = re.exec(text);
    if (m) {
      ret[m[1]] = m[2] + '';
    }
  } while (m);
  return ret;
};

/**
 * Splits up the seed strings we get from the server into objects,
 * with the amount of packs in each pile.
 */
const createSeeds = (seedStrings: Record<string, number> = {}): Seed[] => {
  const seeds = Object.keys(seedStrings).map((key) => {
    const values = splitSeedString(key);
    return {
      ...values,
      amount: seedStrings[key],
      key,
      name: toTitleCase((values.name || '').replace('pack of ', '')),
    };
  });
  return sortBy(seeds, [(seed) => seed.name]);
};

export const SeedExtractor = (props) => {
  const { act, data } = useBackend<Data>();
  const seeds = createSeeds(data.seeds);
  return (
    <Window width={900} height={400}>
      <Window.Content scrollable>
        <Section title="Przechowywane nasiona:">
          <Table textAlign="center">
            <Table.Row header>
              <Table.Cell>Nazwa</Table.Cell>
              <Table.Cell>Długowieczność</Table.Cell>
              <Table.Cell>Wytrzymałość</Table.Cell>
              <Table.Cell>Dojrzewanie</Table.Cell>
              <Table.Cell>Produkcja</Table.Cell>
              <Table.Cell>Plon</Table.Cell>
              <Table.Cell>Moc</Table.Cell>
              <Table.Cell>Zapas</Table.Cell>
            </Table.Row>
            {seeds.map((item) => (
              <Table.Row key={item.key}>
                <Table.Cell bold>{item.name}</Table.Cell>
                <Table.Cell>{item.lifespan}</Table.Cell>
                <Table.Cell>{item.endurance}</Table.Cell>
                <Table.Cell>{item.maturation}</Table.Cell>
                <Table.Cell>{item.production}</Table.Cell>
                <Table.Cell>{item.yield}</Table.Cell>
                <Table.Cell>{item.potency}</Table.Cell>
                <Table.Cell>
                  <Button
                    icon="eject"
                    onClick={() =>
                      act('select', {
                        item: item.key,
                      })
                    }
                  >
                    Wydaj
                  </Button>
                  (zostało: {item.amount})
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
