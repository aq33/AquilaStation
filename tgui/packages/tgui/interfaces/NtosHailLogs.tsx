import { LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  missions: any;
  ship_name: any;
};

const missionStatusToText = (s) => {
  if (s === 2) {
    return 'Misja wykonana!';
  }
  if (s === -1) {
    return 'Misja nieudana!';
  }
  return 'Misja w toku';
};

export const NtosHailLogs = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <NtosWindow resizable width={440} height={650}>
      <NtosWindow.Content scrollable>
        <Section title="Stan statku">
          <LabeledList>
            <LabeledList.Item label="Nazwa">{data.ship_name}</LabeledList.Item>
          </LabeledList>
        </Section>
        <MissionTable />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const MissionTable = (props) => {
  const { act, data } = useBackend<Data>();
  const missions = data.missions || [];
  return (
    <Section title="Misje">
      {missions.map((mission) => (
        <Section
          title={
            'Zlecenie od: ' +
            mission.client +
            ' - ' +
            missionStatusToText(mission.status)
          }
          key={mission}
        >
          {mission.desc}
          <br />
          {'Zapłata: ' + mission.reward}
        </Section>
      ))}
    </Section>
  );
};
