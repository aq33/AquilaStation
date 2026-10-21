import { BlockQuote, LabeledList, Section, Stack } from 'tgui-core/components';

import { Window } from '../layouts';

const tipstyle = {
  color: 'white',
};

const noticestyle = {
  color: 'lightblue',
};

export const AntagInfoNightmare = (props) => {
  return (
    <Window width={620} height={380}>
      <Window.Content backgroundColor="#0d0d0d">
        <Stack fill>
          <Stack.Item width="46.2%">
            <Section fill>
              <Stack vertical fill>
                <Stack.Item fontSize="25px">Jesteś Koszmarem.</Stack.Item>
                <Stack.Item>
                  <BlockQuote>
                    Jesteś istotą spoza gwiazd, która w ciemności dysponuje
                    ogromną mocą i staje się niemal niepokonana. Niestety w
                    świetle więdniesz i spalasz się. Użyj swojego
                    <span style={noticestyle}>&ensp;pożeracza światła</span>,
                    aby przyciemnić stację i ułatwić sobie polowanie.
                  </BlockQuote>
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item textColor="label">
                  <span style={tipstyle}>Rada #1:&ensp;</span>
                  Często zmieniaj miejsce. Gdy cię odkryją, cała stacja zacznie
                  na ciebie polować, więc nie zostawaj długo w jednym rejonie.
                  <br />
                  <span style={tipstyle}>Rada #2:&ensp;</span>
                  Wybieraj nierówne walki. Jeden na jednego jesteś niezwykle
                  silny, korzystaj z tego. Im więcej walczysz, tym trudniej
                  utrzymać ciemność.
                  <br />
                  <span style={tipstyle}>Rada #3:&ensp;</span>
                  Gdy możesz, niszcz APC do końca. Zamiast polować na lampy,
                  które łatwo naprawić, poluj na APC, których naprawa jest
                  trudniejsza.
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item width="53%">
            <Section fill title="Moce">
              <LabeledList>
                <LabeledList.Item label="Taniec cieni">
                  W cieniu jesteś odporny na wszystkie ataki dystansowe i szybko
                  regenerujesz zdrowie.
                </LabeledList.Item>
                <LabeledList.Item label="Krok cienia">
                  W ciemności możesz poruszać się bez żadnych ograniczeń.
                  Światło cię z tego wyrwie.
                </LabeledList.Item>
                <LabeledList.Item label="Serce ciemności">
                  Twoje serce przyzywa cienie. Jeśli zginiesz w ciemności i
                  zostaniesz w spokoju, z czasem odrodzisz się.
                </LabeledList.Item>
                <LabeledList.Item label="Pożeracz światła">
                  Twoja wykręcona kończyna. Pochłania światło wszystkiego, czego
                  dotknie, czy to ofiary, czy przedmiotu.
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
