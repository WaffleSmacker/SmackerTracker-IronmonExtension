# SmackerTracker-IronmonExtension
An Ironmon Tracker extension: Track your seed data! <br>
Created by [WaffleSmacker](https://www.twitch.tv/wafflesmacker)

## Shoutouts
- madthehead - Created the html, js, and css for the dashboard
- utdzac - For continuing to update the tracker and make all this possible

## Requirements
- [Ironmon-Tracker v8.4.1](https://github.com/besteon/Ironmon-Tracker) or higher

## Download & Install
1) Download the [latest release](https://github.com/WaffleSmacker/SmackerTracker-IronmonExtension/releases/latest) of this extension from the GitHub's Releases page
2) If you downloaded a `.zip` file, first extract the contents of the `.zip` file into a new folder
3) Put the extension file(s) in the existing "**extensions**" folder found inside your Tracker folder
   - The file(s) should appear as: `[YOUR_TRACKER_FOLDER]/extensions/SmackerTracker.lua`
   - The folder should appear as: `[YOUR_TRACKER_FOLDER]/extensions/SmackerTracker`
4) On the Tracker settings menu (click the gear icon on the Tracker window), click the "**Extensions**" button
5) In the Extensions menu, enable "**Allow custom code to run**" (if it is currently disabled)
6) Click the "**Install New**" button at the bottom to check for newly installed extensions
   - If you don't see anything in the extensions list, double-check the extension files are installed in the right location. Refer to the [Tracker wiki documentation](https://github.com/besteon/Ironmon-Tracker/wiki/Tracker-Add-ons#install-and-setup-1) if you need additional help
7) Click on the "**[BETA]SmackerTracker**" extension button to view the extension and turn it on

## How to use
Simply turn the extension on when you are playing IronMon. <br>
Whenever your pokemon's HP goes to zero it will save data about your run into a csv file named "**ironmon-seed-data.csv**". <br>
The data of your seeds and the dashboard will be saved in "**extensions/SmackerTracker**". <br><br>

![image](https://github.com/WaffleSmacker/SmackerTracker-IronmonExtension/assets/131427794/6ca36cf2-7a50-4e97-bc49-6b5fec2bfcfd)
<br><br>

### To Open the Dashboard
When you get the Game Over screen, click the NotePad Icon.
After you open the dash, you only need to refresh the page to update to the most recent data.

![image](https://github.com/WaffleSmacker/SmackerTracker-IronmonExtension/assets/131427794/e9d3322a-91ca-4305-9f1d-d5877d1889a5)


## Dashboard
The dashboard contains multiple data points of your runs.
1) Aggregated Stats - See an aggregated summary of all of your runs.
2) Filters - Select these to adjust which data you want to see.
3) Recent Summary Run - Shows the most recent run OR displays info of a mon you select in section 4.
4) Detailed Data - Shows a detailed view of all your IronMon runs since you started using this extension.

![image](https://github.com/WaffleSmacker/SmackerTracker-IronmonExtension/assets/131427794/83b0f963-fed5-4117-b597-af6afcdfa15e)
