export enum Gender {
  Male = 'male',
  Female = 'female',
  Other = 'plural',
}

export const GENDERS = {
  [Gender.Male]: {
    icon: 'male',
    text: 'On/jego',
  },

  [Gender.Female]: {
    icon: 'female',
    text: 'Ona/jej',
  },

  [Gender.Other]: {
    icon: 'tg-non-binary',
    text: 'Oni/ich',
  },
};
