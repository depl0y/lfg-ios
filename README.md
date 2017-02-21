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
