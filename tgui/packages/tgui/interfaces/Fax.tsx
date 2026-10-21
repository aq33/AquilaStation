import { sortBy } from 'es-toolkit';
import { Box, Button, LabeledList, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type FaxData = {
  faxes: FaxInfo[];
  fax_id: string;
  fax_name: string;
  visible: boolean;
  has_paper: string;
  access_additional_faxes: boolean;
  // Uwaga: w kluczu z DM pierwsza litera to cyrylickie „с” (tak samo w fax.dm).
  сan_switch_access: boolean;
  additional_faxes_list: AdditionalFaxesList[];
  syndicate_network: boolean;
  syndicate_faxes_list: AdditionalFaxesList[];
  fax_history: FaxHistory[] | null;
};

type FaxInfo = {
  fax_name: string;
  fax_id: string;
  visible: boolean;
  has_paper: boolean;
  syndicate_network: boolean;
};

type AdditionalFaxesList = {
  fax_name: string;
  button_color: string;
};

type FaxHistory = {
  history_type: string;
  history_fax_name: string;
  history_time: string;
};

const HISTORY_TYPE_NAMES: Record<string, string> = {
  Send: 'Wysłano',
  Receive: 'Odebrano',
};

export const Fax = (props) => {
  const { act, data } = useBackend<FaxData>();
  const faxes = data.faxes
    ? sortBy(
        data.syndicate_network
          ? data.faxes.filter((filterFax: FaxInfo) => filterFax.visible)
          : data.faxes.filter(
              (filterFax: FaxInfo) =>
                filterFax.visible && !filterFax.syndicate_network,
            ),
        [(sortFax: FaxInfo) => sortFax.fax_name],
      )
    : [];
  // AQUILA: dodatkowe faksy (Centrala itd.) po zalogowaniu i lista Syndykatu
  const additional_faxes = data.access_additional_faxes
    ? data.additional_faxes_list || []
    : [];
  const syndicate_faxes = data.syndicate_network
    ? data.syndicate_faxes_list || []
    : [];
  const special_networks = [...additional_faxes, ...syndicate_faxes];
  const fax_history = data.fax_history || [];
  return (
    <Window width={340} height={540}>
      <Window.Content scrollable>
        <Section title="O faksie">
          <LabeledList>
            <LabeledList.Item label="Nazwa w sieci">
              {data.fax_name}
            </LabeledList.Item>
            <LabeledList.Item label="ID w sieci">
              {data.fax_id}
            </LabeledList.Item>
            <LabeledList.Item label="Widoczny w sieci">
              {data.visible ? 'tak' : 'nie'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Papier"
          buttons={
            <Button
              icon="eject"
              onClick={() => act('remove')}
              disabled={!data.has_paper}
            >
              Wyjmij
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Podajnik">
              {data.has_paper ? (
                <Box color="green">Papier w podajniku</Box>
              ) : (
                <Box color="red">Brak papieru</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Wyślij"
          buttons={
            <Button
              color={data.access_additional_faxes ? 'bad' : 'good'}
              onClick={() => act('access_additional_faxes_toggle')}
              disabled={!data.сan_switch_access}
              tooltip="Dostęp do rozszerzonej listy faksów."
            >
              {data.access_additional_faxes ? 'Wyloguj' : 'Zaloguj'}
            </Button>
          }
        >
          {faxes.length === 0 && special_networks.length === 0 ? (
            'Faks nie wykrył w sieci żadnych innych faksów.'
          ) : (
            <Box mt={0.4}>
              {special_networks.map((fax: AdditionalFaxesList) => (
                <Button
                  key={fax.fax_name}
                  tooltip={fax.fax_name}
                  disabled={!data.has_paper}
                  backgroundColor={fax.button_color}
                  onClick={() =>
                    act('send_to_additional_fax', {
                      name: fax.fax_name,
                      color: fax.button_color,
                    })
                  }
                >
                  {fax.fax_name}
                </Button>
              ))}
              {faxes.map((fax: FaxInfo) => (
                <Button
                  key={fax.fax_id}
                  tooltip={fax.fax_name}
                  disabled={!data.has_paper}
                  color={fax.syndicate_network ? 'red' : 'blue'}
                  onClick={() =>
                    act('send', {
                      id: fax.fax_id,
                      name: fax.fax_name,
                    })
                  }
                >
                  {fax.fax_name}
                </Button>
              ))}
            </Box>
          )}
        </Section>
        <Section
          title="Historia"
          buttons={
            <Button
              icon="trash"
              onClick={() => act('history_clear')}
              disabled={!fax_history.length}
            >
              Wyczyść
            </Button>
          }
        >
          <Table>
            {fax_history.map((history: FaxHistory, index) => (
              <Table.Row key={index}>
                <Table.Cell
                  collapsing
                  color={history.history_type === 'Send' ? 'green' : 'red'}
                >
                  {HISTORY_TYPE_NAMES[history.history_type] ||
                    history.history_type}
                </Table.Cell>
                <Table.Cell>
                  {history.history_fax_name} - {history.history_time}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
