import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  ais: any;
  borg: any;
  cell: any;
  channels: any;
  laws: any;
  modules: any;
  upgrades: any;
};

export const BorgPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const borg = data.borg || {};
  const cell = data.cell || {};
  const cellPercent = cell.charge / cell.maxcharge;
  const channels = data.channels || [];
  const modules = data.modules || [];
  const upgrades = data.upgrades || [];
  const ais = data.ais || [];
  const laws = data.laws || [];
  return (
    <Window title="Panel borga" theme="admin" width={700} height={700}>
      <Window.Content scrollable>
        <Section
          title={borg.name}
          buttons={
            <Button
              icon="pencil-alt"
              content="Zmień nazwę"
              onClick={() => act('rename')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Stan">
              <Button
                icon={borg.emagged ? 'check-square-o' : 'square-o'}
                content="Zemagowany"
                selected={borg.emagged}
                onClick={() => act('toggle_emagged')}
              />
              <Button
                icon={borg.lockdown ? 'check-square-o' : 'square-o'}
                content="Zablokowany"
                selected={borg.lockdown}
                onClick={() => act('toggle_lockdown')}
              />
              <Button
                icon={borg.scrambledcodes ? 'check-square-o' : 'square-o'}
                content="Zakłócone kody"
                selected={borg.scrambledcodes}
                onClick={() => act('toggle_scrambledcodes')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Ładunek">
              {!cell.missing ? (
                <ProgressBar value={cellPercent}>
                  {`${cell.charge} / ${cell.maxcharge}`}
                </ProgressBar>
              ) : (
                <span className="color-bad">Brak ogniwa</span>
              )}
              <br />
              <Button
                icon="pencil-alt"
                content="Ustaw"
                onClick={() => act('set_charge')}
              />
              <Button
                icon="eject"
                content="Wymień"
                onClick={() => act('change_cell')}
              />
              <Button
                icon="trash"
                content="Usuń"
                color="bad"
                onClick={() => act('remove_cell')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Kanały radiowe">
              {channels.map((channel) => (
                <Button
                  key={channel.name}
                  icon={channel.installed ? 'check-square-o' : 'square-o'}
                  content={channel.name}
                  selected={channel.installed}
                  onClick={() =>
                    act('toggle_radio', {
                      channel: channel.name,
                    })
                  }
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Moduł">
              {modules.map((module) => (
                <Button
                  key={module.type}
                  icon={
                    borg.active_module === module.type
                      ? 'check-square-o'
                      : 'square-o'
                  }
                  content={module.name}
                  selected={borg.active_module === module.type}
                  onClick={() =>
                    act('setmodule', {
                      module: module.type,
                    })
                  }
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Ulepszenia">
              {upgrades.map((upgrade) => (
                <Button
                  key={upgrade.type}
                  icon={upgrade.installed ? 'check-square-o' : 'square-o'}
                  content={upgrade.name}
                  selected={upgrade.installed}
                  onClick={() =>
                    act('toggle_upgrade', {
                      upgrade: upgrade.type,
                    })
                  }
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Nadrzędne SI">
              {ais.map((ai) => (
                <Button
                  key={ai.ref}
                  icon={ai.connected ? 'check-square-o' : 'square-o'}
                  content={ai.name}
                  selected={ai.connected}
                  onClick={() =>
                    act('slavetoai', {
                      slavetoai: ai.ref,
                    })
                  }
                />
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Prawa"
          buttons={
            <Button
              icon={borg.lawupdate ? 'check-square-o' : 'square-o'}
              content="Synchronizacja praw"
              selected={borg.lawupdate}
              onClick={() => act('toggle_lawupdate')}
            />
          }
        >
          {laws.map((law) => (
            <Box key={law}>{law}</Box>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
