import { NtosWindow } from '../layouts';
import { SupermatterMonitorContent } from './SupermatterMonitor';

export const NtosSupermatterMonitor = (props) => {
  return (
    <NtosWindow width={700} height={400}>
      <NtosWindow.Content>
        <SupermatterMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
