import { useBackend } from '../backend';
import { Collapsible, Section, Table } from '../components';
import { Window } from '../layouts';

type Data = {
  clans: ClanInfo[];
};

type ClanInfo = {
  clan_name: string;
  clan_desc: string;
};

export const KindredBook = (props) => {
  const { data } = useBackend<Data>();
  const { clans } = data;
  return (
    <Window width={410} height={460} theme="spooky">
      <Window.Content scrollable>
        <Section title="Klany wampirów">
          <Table mb={2}>
            <Table.Row>
              Spisana przez pokolenia kuratorów, ta księga zawiera wszystko, co
              my, kuratorzy, wiemy o nieumarłym zagrożeniu czyhającym na
              stację...
            </Table.Row>
            <Table.Row>Który klan cię zatem interesuje?</Table.Row>
          </Table>
          <Table>
            <Table.Row>
              {clans.map((clan) => (
                <Collapsible key={clan.clan_name} title={clan.clan_name}>
                  <Table.Cell color="label">{clan.clan_desc}</Table.Cell>
                </Collapsible>
              ))}
            </Table.Row>
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
