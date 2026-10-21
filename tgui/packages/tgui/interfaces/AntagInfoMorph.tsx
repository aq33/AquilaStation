import { BlockQuote, Stack } from 'tgui-core/components';

import { Window } from '../layouts';

const goodstyle = {
  color: 'lightgreen',
};

const badstyle = {
  color: 'red',
};

const noticestyle = {
  color: 'lightblue',
};

// AQUILA: opis zgodny z naszym morfem (zasadzka z jadem, przewody wentylacyjne)
export const AntagInfoMorph = (props) => {
  return (
    <Window width={620} height={280} theme="abductor">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item fontSize="25px">Jesteś morfem...</Stack.Item>
          <Stack.Item>
            <BlockQuote>
              ...zmiennokształtną abominacją, która potrafi zjeść prawie
              wszystko. Możesz przybrać postać czegokolwiek, co widzisz,{' '}
              <span style={noticestyle}>klikając to z Shiftem.</span>{' '}
              <span style={badstyle}>
                &ensp;Zauważą to pobliscy obserwatorzy.
              </span>{' '}
              W przebraniu poruszasz się szybciej, ale zadajesz mniej obrażeń i
              nie możesz niczego jeść. Do tego
              <span style={badstyle}>
                &ensp;każdy w promieniu trzech pól, kto ci się przyjrzy, wyczuje
                niepokojącą nienaturalność.
              </span>{' '}
              Kto dotknie cię gołą ręką, gdy jesteś w przebraniu, wpadnie w{' '}
              <span style={goodstyle}>zasadzkę</span> - przewrócisz go i
              wstrzykniesz mu <span style={goodstyle}>wyniszczający jad</span>.
              Możesz zaatakować dowolny przedmiot lub martwą istotę, aby ją
              pożreć -
              <span style={goodstyle}>
                &ensp;zwłoki przywracają ci zdrowie.
              </span>{' '}
              Po przewodach wentylacyjnych możesz się czołgać,{' '}
              <span style={noticestyle}>klikając je z Altem</span>. Wreszcie, do
              pierwotnej postaci wracasz,{' '}
              <span style={noticestyle}>klikając siebie z Shiftem.</span>
            </BlockQuote>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
