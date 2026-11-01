import { Component } from 'react';
import { Box, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = Record<string, any>;

const logTextAlways = `
----------------------------------------
      Crypto-breaker 2400 Edition
----------------------------------------
`;
const logTextPrependAlways = `
Sekwencja kryptograficzna przyjęta.


Odbieranie zrzutu kluczy...


Zrzut kluczy pobrany.


Uruchamianie protokołów brute-force.


Nawiązano połączenie z Syndix.


Zdalne przetwarzanie aktywne.


Aktywne!



`;
const logText = `

Wysyłanie rootkita...


Uzyskano uprawnienia roota.






Nawiązywanie połączenia programowego...


Aktywne!





Włączanie protokołów autodestrukcji...


Aktywne!





Usuwanie limitów pakietów...


Gotowe!







Sekwencja kryptograficzna zakończona.
`;

const FPS = 120;
const tickInterval = 1000 / FPS;

export const NtosEmagConsole = (props) => {
  return (
    <NtosWindow title="Crypto-breaker 2400 Edition" width={400} height={500}>
      <NtosWindow.Content>
        <EmagConsoleText log_text={logText} />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export class EmagConsoleText extends Component<any, any> {
  [key: string]: any;

  constructor(props) {
    super(props);
    this.timer = null;
    this.state = {
      index: 0,
    };
    this.text = logTextPrependAlways + this.props.log_text;
  }

  tick() {
    const { props, state } = this;
    if (state.index < this.text.length) {
      this.setState({ index: state.index + 1 * (props?.frame_skip || 1) });
    } else {
      clearTimeout(this.timer);
      this.timer = setTimeout(() => {
        const { act } = useBackend<Data>();
        // All UI actions close the program
        act('PC_exit');
      }, this.props.end_pause || 500);
    }
  }

  componentDidMount() {
    this.timer = setInterval(() => this.tick(), tickInterval);
  }

  componentWillUnmount() {
    clearTimeout(this.timer);
  }

  render() {
    const { state } = this;
    const toShow = this.text.substring(
      0,
      Math.min(state.index, this.text.length),
    );
    return (
      <Section fill scrollable backgroundColor="black">
        {(logTextAlways + toShow).split('\n').map((log) =>
          log !== '\n' ? (
            <Box mb={1} key={log}>
              <span style={{ color: 'white' }}>{log}</span>
            </Box>
          ) : null,
        )}
      </Section>
    );
  }
}
