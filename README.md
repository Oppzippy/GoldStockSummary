# Gold Stock Summary

Tracks gold across all characters on an account and exports to csv/json. Guild bank money is included for characters that are guild masters.

## Download

[CurseForge](https://www.curseforge.com/wow/addons/gold-stock-summary)  
[Wago](https://addons.wago.io/addons/gold-stock-summary)  
[WoWInterface](https://www.wowinterface.com/downloads/info26374-GoldStockSummary.html)  
[GitHub](https://github.com/Oppzippy/GoldStockSummary/releases)

## Commands

/goldstocksummary (or /gss) to show the Gold Stock Summary UI.

## Export

The following fields are exported:

- `name`
- `realm` Realm
- `faction` Faction
- `totalMoney`
- `personalMoney`
- `guildBankMoney`
- `lastUpdate`

### CSV

When using CSV export, the unit used for money is gold. Note that the column names are localized.

### JSON

When using JSON export, the unit used for money is copper. All money fields will be strings since the gold cap (in copper) is larger than the maximum value of a 32 bit integer.

Schema:

```ts
type JSONExport =
  | {
      type: "characters";
      data: Character[];
    }
  | {
      type: "realms";
      data: Realm[];
    };

type Character = {
  name: string; // Character name
  realm: string; // Character realm name
  faction: "alliance" | "horde" | "neutral"; // Character faction
  totalMoney: string; // Money in bags plus money in the guild bank if the character is the guild master.
  personalMoney: string; // Money in bags.
  guildMoney?: string; // Money in the guild bank if the character is the guild master.
  lastUpdate?: string; // Date and time of the last time this character's money was updated as ISO 8601.
};

type Realm = {
  realm: string; // Realm name
  faction: "alliance" | "horde" | "neutral"; // Alliance and horde are separated per realm
  totalMoney: string; // Sum of total money for all characters on the realm and faction.
  personalMoney: string; // Sum of personal money for all characters on the realm and faction.
  guildMoney: string; // Sum of guild money for all characters on the realm and faction.
};
```
