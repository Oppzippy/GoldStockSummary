# GoldTracker

Tracks gold across all characters on an account.

## Commands

/goldtracker to show the GoldTracker UI.

## Export

The following fields are exported:

- `name` Character name
- `realm` Realm
- `faction` Faction
- `totalMoney` Money in bags plus money in the guild bank if the character is the guild master.
- `personalMoney` Money in bags
- `guildBankMoney` Money in the guild bank if the character is the guild master.
- `lastUpdate` Date and time of the last time this character's money was updated.

### CSV

When using CSV output, the unit used for money is gold. Note that the column names are localized.

### JSON

When using JSON output, the unit used for money is copper.

Characters Schema:

```ts
type Characters = {
  name: string;
  realm: string;
  faction: "alliance" | "horde" | "neutral";
  // Money is a string since the gold cap (in copper) is larger than the maximum value of a 32 bit integer.
  totalMoney: string;
  personalMoney: string;
  guildMoney?: string;
  lastUpdate?: string; // ISO 8601
}[];
```

Realms Schema:

```ts
type Realms = {
  realm: string;
  faction: "alliance" | "horde" | "neutral";
  // Money is a string since the gold cap (in copper) is larger than the maximum value of a 32 bit integer.
  totalMoney: string;
  personalMoney: string;
  guildMoney: string;
}[];
```
