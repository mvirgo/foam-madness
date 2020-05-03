# Foam Madness

Simulating a Basketball Tournament on iOS

## App Summary

This app was made as a fun way to pass the time with a basketball hoop and ball 
(whether mini or full-size) during shelter-in-place in Spring 2020, 
with a certain college tournament otherwise cancelled.

You can find a full summary of the rules on the App Store:

[<img src="app-store-badge.svg">](https://apps.apple.com/us/app/foam-madness/id1507627005)

### App Notes

The current version of the app was compiled using Swift 5 and the iOS 13 SDK,
although v1 of the app originally used Swift 4.2 and the iOS 12.1 SDK.

The app supports darks mode.

### Github Pages

You can find the Privacy Policy and Support Page [here](https://mvirgo.github.io/foam-madness/)
on Github Pages.

### 2020 Simulation Results

My main reason for building the app was so I could simulate the 2020 Tournament that was cancelled.
I need to build a bracket view for easier viewing, but you can see each game's stats by its id with the following:

```
https://mvirgo.github.io/foam-madness/gameStats?games={game_id}
```

E.g., the Championship game is game ID 66 (the 67th game, starting from zero), so you'd go to

```
https://mvirgo.github.io/foam-madness/gameStats?games=66
```

Feel free to start with the first game (game id "0") [here](https://mvirgo.github.io/foam-madness/gameStats?games=0).
