# game-jam-prep

Shared base for our game-jam side-scroller. Branch off `main-sideScroller`
to start your feature — it's deliberately a minimal, working foundation, not
the finished game.

## Running it

Open the project in Godot 4.6 and press Play. The main scene is
`Levels/Base/Base.tscn`: a player you can walk and jump around a bounded
level with a tree. That's the whole base — add your own mechanics on top.

**Controls:** `A` / `D` move, `Space` jumps. (`W` / `S` and the rest of the
input map are still defined for whoever needs them.)

## Folder layout

Keep new files in the matching folder so the project stays tidy:

```
Entities/            things that live in the world
  Player/            the player
    Player.tscn        side-scroller player (the base)
    theRealMC.tscn     Matthew's original top-down player (kept for reference)
    scripts/           player controllers
    Art/               player sprites (CuteFatPigeon, ...)
  Enemies/           enemy art + scenes
  Props/             non-enemy world objects (Tree, ...)
Globals/             shared systems
  Spawner/           Matthew's configurable enemy spawner
Levels/              level scenes
  Base/Base.tscn       the shared base level (main scene)
  Common/Art/          shared level art (tilesets, ...)
addons/              editor plugins (see below) — leave enabled
```

### Base level structure

`Base.tscn` is organised into clear sections so everyone's work has an
obvious home (this mirrors Matthew's layout-plugin setup):

- **Systems** — spawners, managers, game-state helpers
- **World**
  - **Background** — sky / parallax
  - **Level** — ground, borders, props (the static world)
  - **Entities** — player, enemies, projectiles (the moving things)
- **Effects** — particles, transient visuals
- **HUDLayer / PauseLayer / DebugLayer** — UI overlays

## Editor plugins (Matthew's)

Both are enabled in `project.godot` — please keep them on:

- **PropertiesForTheDiscerningIndividual** — extra Inspector property types.
  The spawner uses these, so it needs to stay enabled.
- **NewProjectLayoutSetup** — `Project -> Tools -> Quick Layout Setup`, sets
  up the organised scene layout above.
