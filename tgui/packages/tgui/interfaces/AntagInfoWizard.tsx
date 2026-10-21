import { Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

const teleportstyle = {
  color: 'yellow',
};

const robestyle = {
  color: 'lightblue',
};

const destructionstyle = {
  color: 'red',
};

const defensestyle = {
  color: 'orange',
};

const transportstyle = {
  color: 'yellow',
};

const summonstyle = {
  color: 'cyan',
};

const ritualstyle = {
  color: 'violet',
};

type Info = {
  objectives: Objective[];
};

// AQUILA: bez Wielkiego Rytuału, osobistej misji i gotowych zestawów z tg - nie mamy ich
export const AntagInfoWizard = (props) => {
  const { data } = useBackend<Info>();
  const { objectives } = data;

  return (
    <Window width={620} height={630} theme="wizard">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section scrollable fill>
              <Stack vertical>
                <Stack.Item textColor="red" fontSize="20px">
                  Jesteś Kosmicznym Czarodziejem!
                </Stack.Item>
                <Stack.Item>
                  <ObjectivePrintout
                    objectives={objectives}
                    titleMessage="Federacja Kosmicznych Czarodziejów powierzyła ci następujące zadania"
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section fill title="Księga zaklęć">
              <Stack vertical fill>
                <Stack.Item>
                  Masz księgę zaklęć, która jest z tobą związana. Wybierzesz w
                  niej swój magiczny arsenał.
                  <br />
                  <span style={destructionstyle}>
                    Strona ofensywna zawiera zaklęcia bojowe do niszczenia
                    wrogów.
                  </span>
                  <br />
                  <span style={defensestyle}>
                    Strona defensywna zawiera zaklęcia obronne, które utrzymają
                    cię przy życiu. Pamiętaj: możesz być potężny, ale wciąż
                    jesteś tylko człowiekiem.
                  </span>
                  <br />
                  <span style={transportstyle}>
                    Strona mobilności zawiera zaklęcia ruchu - bardzo ważne, aby
                    przeżyć i załatwić swoje sprawy.
                  </span>
                  <br />
                  <span style={summonstyle}>
                    Strona wsparcia zawiera przywołania i inne pomocne zaklęcia,
                    dzięki którym nie walczysz sam. Uważaj, nie każde
                    przywołanie jest po twojej stronie.
                  </span>
                  <br />
                  <span style={ritualstyle}>
                    Strona rytuałów zawiera potężne efekty globalne, które
                    nastawią stację przeciwko sobie. Pamiętaj, że są albo
                    drogie, albo tylko dla efektu.
                  </span>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Pozostały ekwipunek">
              <Stack>
                <Stack.Item>
                  <span style={teleportstyle}>Zwój teleportacji:</span> 4
                  użycia, aby przenieść się, gdzie zechcesz. Nie wrócisz już do
                  kryjówki, więc przed wyruszeniem przygotuj wszystko.
                  <br />
                  <span style={robestyle}>Szaty czarodzieja:</span> potrzebne do
                  rzucania większości zaklęć. Księga podpowie ci, których zaklęć
                  nie rzucisz bez szat.
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section textAlign="center" textColor="red" fontSize="20px">
              Pamiętaj: nie zapomnij przygotować zaklęć.
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
