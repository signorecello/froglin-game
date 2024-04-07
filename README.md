# Froglin's Universe

![cover_image](./cover.png)

Froglins are strange creatures all around us. They exist only in cryptography terms, and can be captured and become friends through the use of Zero-Knowledge Proofs.

This repo is the Froglin's Universe source code.

Check out the [game specs](https://zpedro.notion.site/Froglin-s-Universe-fded1b64f3e041e0824318dc82aafdc2?pvs=4) to understand what's the goal and why are we doing this.

## Structure

The monorepo has two main packages:

- Game: exports a class Game where all meaningful actions take place, such as capturing froglins, fighting, claiming your mana, etc.
- Game Lib: exports all the needed classes and assets to execute and prove the game, such as Player, Froglin, etc

Both packages are a mixture of Typescript and Noir:

- Typescript: Where all the simulation and execution happens. This is the "optimistic" state of the game, before actions are proven and verified.
- Noir: The ZKDSL that allows for the actions of the game to be proven and verified.

## Testing

You can test this library by running `yarn` followed by `yarn test`.

This will run the unit tests inside `game_lib` and the e2e tests in `game`.

## How can I develop a frontend for Froglin's Universe

Currently, Froglin's Universe doesn't have a frontend. We're open to contributions! If you want to develop a frontend for Froglin's Universe, please reach out on Telegram at @zpedro_eth.

We don't currently publish to `npm` but feel free to simply add a new package to "packages" and use `"@froglin/game": "workspace:*"` as a dependency.

The project is fully built in TS so you should be able to navigate all the current actions and properties of the Game class.

## Game assets

### Zones

One yet-to-be-decided concept of the game is the idea of Zones. Hipothetically they would come from the user's device.

For now, I've just drawn a table with two Zones to help me navigate the coordinates:

|     | 000     | 100     | 200 | 300 | 400    | 500    |
|-----|---------|---------|-----|-----|--------|--------|
| 000 | Prairie | Prairie |     |     |        |        |
| 100 | Prairie | Prairie |     |     |        |        |
| 200 |         |         |     |     |        |        |
| 300 |         |         |     |     |        |        |
| 400 |         |         |     |     | Forest | Forest |
| 500 |         |         |     |     | Forest | Forest |
