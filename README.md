# LFG Pub iOS Client

## API Usage

Currently the iOS client uses the following API calls to fetch and post information:

### Fetch games list
#### Request info
URL: `https://lfg.pub/api/v2/activities`  
Method: `GET`

#### Results

The results include all the languages supported by LFG Pub and all `activities` currently publicly available.


```
{
  "languages" : [
    {
      "id" : 1,
      "identifier" : "nl",
      "title" : "Dutch"
    }
  ],
  "activities" : [
    {
      "id" : 1,
      "config_url" : "http://lfg.pub/api/v2/activity/destiny",
      "permalink" : "destiny",
      "name" : "Destiny",
      "icon" : "https://cdn.lfg.pub/images/activities/destiny/icon.jpg",
      "banner" : "https://cdn.lfg.pub/images/activities/destiny/banner.jpg",
      "background" : "https://cdn.lfg.pub/images/activities/destiny/background.jpg",
      "popularity" : 0.0716022,
      "release_date" : null,
      "url" : "/destiny",
      "groups" : [
        {
          "id" : 3,
          "name" : "Xbox One",
          "icon" : "ion-xbox"
        },
        {
          "id" : 2,
          "name" : "Xbox 360",
          "icon" : "ion-xbox"
        },
        {
          "id" : 5,
          "name" : "PS4",
          "icon" : "ion-playstation"
        },
        {
          "id" : 4,
          "name" : "PS3",
          "icon" : "ion-playstation"
        }
      ],
      "discord_info" : {
        "id" : 6,
        "channel_name" : "destiny",
        "server_id" : "205009669247336457",
        "invite_code" : "5Tyfjap"
      }
    }
  ]
}

```



##### Activity
| Property | Description |
|----------|-------------|
| id | Internal identifier for the game |
| config_url | This url can be queried to get the game-specific configuration, needed for querying and creating requests |
| permalink | Permalink under which the game is available |
| icon | URL to the icon used for this game |
| banner | URL to the banner used for the game-specific page |
| background | Experimental, often this is empty |
| popularity | Popularity of this game, recalculated every 5 minutes |
| release_date | If the game isn't out yet, this will contain a date when the game is released |
| url | The relative URL to the LFG Pub page for the game |
| groups | A collection of platforms this game is available on |
| discord_info | Information about the Discord invite that is displayed on the game specific page |

##### Group
| Property | Description |
|----------|-------------|
| id | Internal identifier for the group/platform |
| name | Display name of the platform |
| icon | The icon we use to accompany the platform, sometimes this is empty |

##### Language
| Property | Description |
|----------|-------------|
| id | Internal identifier for the language |
| identifier | The locale identifier for the language |
| Title | Display text for the language |

##### Discord Info
| Property | Description |
|----------|-------------|
| id | Internal identifier for the discord invite |
| channel_name | The name of the discord channel for this game |
| server_id | Our server id, used to let you join |
| invite_code | A non-expired invite code, used to let you guys join our Discord server |

### Fetch game configuration
#### Request info
URL: `https://lfg.pub/api/v2/activity/<permalink>`

The `<permalink>` in the URL should be replaced with a permalink of a game fetched with the query above.

#### Results
This will return the field configuration for the specified game.

```
{
  "fields" : [
    {
      "name" : "Game",
      "permalink" : "game",
      "objects" : [
        {
          "id" : 37,
          "permalink" : "character-type",
          "name" : "Character type",
          "description" : null,
          "group" : "Game",
          "icon" : "ion-speedometer",
          "options" : [
            {
              "id" : 6,
              "permalink" : "hunter",
              "name" : "Hunter",
              "group" : null,
              "lfg" : true,
              "lfm" : true,
              "sortorder" : 0
            }, ...
          ],
          "datatype" : "option",
          "min" : 0,
          "max" : 100,
          "sortorder" : 2,
          "lfg" : true,
          "lfm" : true,
          "filterable" : true,
          "show_in_list" : true,
          "step" : 1,
          "filter_step" : 1,
          "value_prefix" : null,
          "value_suffix" : null,
          "display_as_checkboxes" : false
        }, ...
      ]
    },
    {
      "name" : "Player",
      "permalink" : "player",
      "objects" : [
        {
          "id" : 13,
          "permalink" : "quickrun",
          "name" : "Quickrun",
          "description" : null,
          "group" : "Player",
          "icon" : null,
          "options" : [],
          "datatype" : "boolean",
          "min" : 0,
          "max" : 100,
          "sortorder" : 4,
          "lfg" : true,
          "lfm" : true,
          "filterable" : true,
          "show_in_list" : true,
          "step" : 1,
          "filter_step" : 1,
          "value_prefix" : null,
          "value_suffix" : null,
          "display_as_checkboxes" : false
        }, ...
      ]
    }, ...
  ]
}

```

##### FieldGroup
| Property | Description |
|----------|-------------|
| name | Name of this field group |
| permalink | Identifier for this field group |
| objects | A collection of fields that are within this group |

##### Field
| Property | Description |
|----------|-------------|
| id | Internal identifier for this field |
| permalink | Permalink, used for creating a new request |
| name | Display name |
| description | Description (optional) |
| group | The name of the group this field belongs to, same as the *parent* FieldGroup |
| icon | For some fields and icon is defined, these are mostly fields with the `datatype` boolean |
| options | If the field is op datatype **option**, this will be populated with options the user can choose from |
| datatype | The datatype for the field, see **Datatypes** |
| min | The minimum value for the field, **only used when datatype = number** |
| max | The maximum value for the field, **only used when datatype = number** |
| sortorder | Fields are displayed in a specific order, defined by this field |
| lfg | Is this field available when creating an **LFG** request |
| lfm | Is this field available when creating an **LFM** request |
| filterable | Is this field also available as a filter, used while querying requests? |
| show_in_list | Should this field be displayed in the request's property list? |
| step | The steps a slider should take when dragging, **only used when datatype = number** |
| filter_step | The steps a slider should take when dragging **when filtering**, **only used when datatype = number** |
| value_prefix | Should the display value of this field be prefixed with a certain text? |
| value_suffix | Should the display value of this field be suffixed with a certain text? |
| display_as_checkboxes | Should this **option** field be displayed as multiple checkboxes, instead of one dropdown |

##### FieldOption
| Property | Description |
|----------|-------------|
| id | Internal identifier for this option |
| permalink | Permalink |
| name | Display name |
| group | Is this option in a group, then a name is here |
| lfg | Is this option available when creating an **LFG** request |
| lfm | Is this option available when creating an **LFM** request |
| sortorder | Options are displayed in a specific order, defined by this field |
