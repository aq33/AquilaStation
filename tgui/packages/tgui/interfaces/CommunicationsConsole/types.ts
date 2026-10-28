import type { BooleanLike } from 'tgui-core/react';

export enum ShuttleState {
  BUYING_SHUTTLE = 'buying_shuttle',
  CHANGING_STATUS = 'changing_status',
  MAIN = 'main',
  MESSAGES = 'messages',
  // NSV13 - cele misji
  OBJECTIVES = 'objectives',
}

export type Shuttle = {
  name: string;
  description: string;
  creditCost: number;
  illegal: BooleanLike;
  prerequisites: string | null;
  ref: string;
};

export type Message = {
  // Klucz wybranej odpowiedzi (possible_answers to lista asocjacyjna w DM)
  answered: string | 0;
  content: string;
  title: string;
  possibleAnswers: Record<string, string>;
};

// NSV13 - cele misji
export type Objective = {
  brief: string;
  status: number;
};

export type CommsConsoleData = {
  alertLevel: string;
  alertLevelTick: number;
  authenticated: BooleanLike;
  authorizeName: string;
  budget: number;
  canBuyShuttles: string | 0 | 1;
  canLogOut: BooleanLike;
  canMakeAnnouncement: BooleanLike;
  canMessageAssociates: BooleanLike;
  canPrintAIControlCode: BooleanLike;
  canRecallShuttles: BooleanLike;
  canRequestNuke: BooleanLike;
  // AQUILA: ERT i wybudzanie załogi z kriostazy
  canRequestERT: BooleanLike;
  reinforcementActionReady: BooleanLike;
  crewWakeActionReady: BooleanLike;
  canSendToSectors: BooleanLike;
  canSetAlertLevel: string | BooleanLike;
  canToggleEmergencyAccess: BooleanLike;
  emagged: BooleanLike;
  emergencyAccess: BooleanLike;
  hasConnection: BooleanLike;
  importantActionReady: BooleanLike;
  lineOne: string;
  lineTwo: string;
  messages: Message[];
  page: ShuttleState;
  shuttles: Shuttle[];
  shuttleCalled: BooleanLike;
  shuttleCalledPreviously: BooleanLike;
  shuttleCanEvacOrFailReason: string | 1;
  shuttleLastCalled: string | BooleanLike;
  shuttleRecallable: BooleanLike;
  // NSV13 - cele misji
  announced_objectives: BooleanLike;
  mission_briefing: string;
  notoriety: string;
  objectives: Record<string, Objective>;
  // AQUILA - wybór misji przez kapitana
  mission_choices?: MissionChoice[];
  can_choose_mission?: BooleanLike;

  // static_data
  callShuttleReasonMinLength: number;
  maxMessageLength: number;
  maxStatusLineLength: number;
};

export type MissionChoice = {
  id: string;
  name: string;
  brief: string;
};
