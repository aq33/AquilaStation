import {
  BlockQuote,
  Box,
  Button,
  Icon,
  LabeledList,
  Modal,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { formatTime } from 'tgui-core/format';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type SiteData = {
  name: string;
  ref: string;
  description: string;
  distance: number;
  band_info: Record<string, string>;
  revealed: boolean;
  point_scan_complete: boolean;
  deep_scan_complete: boolean;
};

type ScanData = {
  scan_power: number;
  point_scan_eta: number;
  deep_scan_eta: number;
  site_data: SiteData;
};

const ScanFailedModal = (props) => {
  const { act } = useBackend();
  return (
    <Modal>
      <Stack fill vertical>
        <Stack.Item>
          <Box color="bad">SKAN NIEUDANY!</Box>
        </Stack.Item>
        <Stack.Item>
          <Button content="Potwierdź" onClick={() => act('confirm_fail')} />
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

const ScanSelectionSection = (props) => {
  const { act, data } = useBackend<ScanData>();
  const { scan_power, point_scan_eta, deep_scan_eta, site_data } = data;
  const site = site_data;
  // AQUILA: w tg te pola były czytane z korzenia danych, a DM wysyła je w site_data
  const { point_scan_complete, deep_scan_complete } = site;

  const point_cost = scan_power > 0 ? formatTime(point_scan_eta, 'short') : '∞';
  const deep_cost = scan_power > 0 ? formatTime(deep_scan_eta, 'short') : '∞';
  const scan_available = !point_scan_complete || !deep_scan_complete;
  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section
          fill
          title="Dane miejsca"
          buttons={
            <Button
              content="Wróć"
              onClick={() => act('select_site', { site_ref: null })}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Nazwa">{site.name}</LabeledList.Item>
            <LabeledList.Item label="Opis">
              {site.revealed ? site.description : 'Brak danych'}
            </LabeledList.Item>
            <LabeledList.Item label="Odległość">
              {site.distance}
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Dane spektrograficzne" />
            <LabeledList.Divider />
            {Object.keys(site.band_info).map((band) => (
              <LabeledList.Item key={band} label={band}>
                {site.band_info[band]}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>
      {scan_available && (
        <Stack.Item>
          <Section fill title="Skany">
            {!point_scan_complete && (
              <Section title="Skan punktowy">
                <BlockQuote>
                  Skan punktowy wykonuje podstawowy skan miejsca i ujawnia jego
                  ogólne cechy.
                </BlockQuote>
                <Box>
                  <Button
                    content="Skanuj"
                    disabled={scan_power <= 0}
                    onClick={() => act('start_point_scan')}
                  />
                  <Box inline pl={3}>
                    Szacowany czas: {point_cost}.
                  </Box>
                </Box>
              </Section>
            )}
            {!deep_scan_complete && (
              <Section title="Skan głęboki">
                <BlockQuote>
                  Skan głęboki wykonuje pełny skan miejsca i ujawnia wszystkie
                  szczegóły.
                </BlockQuote>
                <Box>
                  <Button
                    content="Skanuj"
                    disabled={scan_power <= 0}
                    onClick={() => act('start_deep_scan')}
                  />
                  <Box inline pl={3}>
                    Szacowany czas: {deep_cost}.
                  </Box>
                </Box>
              </Section>
            )}
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};

type ScanInProgressData = {
  scan_time: number;
  current_scan_power: number;
  scan_description: string;
};

const ScanInProgressModal = (props) => {
  const { act, data } = useBackend<ScanInProgressData>();
  const { scan_time, current_scan_power, scan_description } = data;

  return (
    <Modal ml={1}>
      <NoticeBox>Trwa skanowanie!</NoticeBox>
      <Box color="danger" />
      <LabeledList>
        <LabeledList.Item label="Podsumowanie skanu">
          {scan_description}
        </LabeledList.Item>
        <LabeledList.Item label="Pozostały czas">
          {formatTime(scan_time)}
        </LabeledList.Item>
        <LabeledList.Item label="Moc anten">
          {current_scan_power}
        </LabeledList.Item>
        <LabeledList.Item label="Zatrzymanie awaryjne">
          <Button.Confirm
            content="ZATRZYMAJ SKAN"
            confirmContent="Na pewno?"
            color="red"
            icon="times"
            onClick={() => act('stop_scan')}
          />
        </LabeledList.Item>
      </LabeledList>
    </Modal>
  );
};

type ExoscannerConsoleData = {
  scan_in_progress: boolean;
  scan_power: number;
  possible_sites: Array<SiteData>;
  wide_scan_eta: number;
  selected_site: string;
  failed: boolean;
  scan_conditions: Array<string>;
};

export const ExoscannerConsole = (props) => {
  const { act, data } = useBackend<ExoscannerConsoleData>();
  const {
    scan_in_progress,
    scan_power,
    possible_sites = [],
    wide_scan_eta,
    selected_site,
    failed,
    scan_conditions = [],
  } = data;

  const can_start_wide_scan = scan_power > 0;

  return (
    <Window width={550} height={600}>
      {!!scan_in_progress && <ScanInProgressModal />}
      {!!failed && <ScanFailedModal />}
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section fill title="Dostępna moc anten">
              <Stack>
                <Stack.Item grow>
                  {(scan_power > 0 && (
                    <>
                      <Box pr={1} inline fontSize={2}>
                        {scan_power}
                      </Box>
                      <Icon name="satellite-dish" size={3} />
                    </>
                  )) ||
                    'Nie wykryto poprawnie ustawionych anten skanujących.'}
                </Stack.Item>
              </Stack>
              <Section title="Specjalne warunki skanu">
                {scan_conditions?.map((condition) => (
                  <NoticeBox key={condition}>{condition}</NoticeBox>
                ))}
              </Section>
            </Section>
          </Stack.Item>
          {!!selected_site && (
            <Stack.Item grow>
              <ScanSelectionSection site_ref={selected_site} />
            </Stack.Item>
          )}
          {!selected_site && (
            <>
              <Stack.Item>
                <Section
                  buttons={
                    <Button
                      icon="search"
                      disabled={!can_start_wide_scan}
                      onClick={() => act('start_wide_scan')}
                    >
                      Skanuj
                    </Button>
                  }
                  fill
                  title="Skan szeroki"
                >
                  <Stack>
                    <Stack.Item>
                      <BlockQuote>
                        Skan szerokopasmowy szuka wszystkiego, czego nie ma na
                        znanych mapach gwiezdnych.
                      </BlockQuote>
                    </Stack.Item>
                    <Stack.Item>
                      Szacowany czas:{' '}
                      {scan_power > 0
                        ? formatTime(wide_scan_eta, 'short')
                        : '∞ minut'}
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section fill title="Skany celowane" scrollable>
                  <Stack vertical>
                    {possible_sites.map((site) => (
                      <Stack.Item key={site.ref}>
                        <Button
                          content={site.name}
                          onClick={() =>
                            act('select_site', { site_ref: site.ref })
                          }
                        />
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              </Stack.Item>
            </>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
