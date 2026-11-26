import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { CoreEjectionData, CoreEjectionSection } from './common/CoreEjection';
import { SupermatterMonitorContent } from './SupermatterMonitor';

export const NtosSupermatterMonitor = (props) => {
  const { data } = useBackend<{ core_ejection?: CoreEjectionData | null }>();
  return (
    <NtosWindow width={700} height={400}>
      <NtosWindow.Content>
        <SupermatterMonitorContent />
        <CoreEjectionSection ejection={data.core_ejection} />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
