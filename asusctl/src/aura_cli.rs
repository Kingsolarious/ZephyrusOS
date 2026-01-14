use std::str::FromStr;

use argh::FromArgs;
use rog_aura::error::Error;
use rog_aura::{AuraEffect, AuraModeNum, AuraZone, Colour, Direction, Speed};

#[derive(FromArgs, Debug, Clone)]
#[argh(
    subcommand,
    name = "aura-power-old",
    description = "aura power (old ROGs and TUF laptops)"
)]
pub struct LedPowerCommand1 {
    #[argh(
        option,
        description = "control if LEDs enabled while awake <true/false>"
    )]
    pub awake: Option<bool>,

    #[argh(
        switch,
        description = "use with awake option; if excluded defaults to false"
    )]
    pub keyboard: bool,

    #[argh(
        switch,
        description = "use with awake option; if excluded defaults to false"
    )]
    pub lightbar: bool,

    #[argh(option, description = "control boot animations <true/false>")]
    pub boot: Option<bool>,

    #[argh(option, description = "control suspend animations <true/false>")]
    pub sleep: Option<bool>,
}

#[derive(FromArgs, Debug, Clone)]
#[argh(subcommand, name = "aura-power", description = "aura power")]
pub struct LedPowerCommand2 {
    #[argh(subcommand)]
    pub command: Option<SetAuraZoneEnabled>,
}

/// Subcommands to enable/disable specific aura zones
#[derive(FromArgs, Debug, Clone)]
#[argh(subcommand)]
pub enum SetAuraZoneEnabled {
    Keyboard(KeyboardPower),
    Logo(LogoPower),
    Lightbar(LightbarPower),
    Lid(LidPower),
    RearGlow(RearGlowPower),
    Ally(AllyPower),
}

/// Keyboard brightness argument helper
#[derive(Debug, Clone)]
pub struct LedBrightness {
    level: Option<u8>,
}

impl LedBrightness {
    pub fn new(level: Option<u8>) -> Self {
        LedBrightness { level }
    }

    pub fn level(&self) -> Option<u8> {
        self.level
    }
}

impl FromStr for LedBrightness {
    type Err = Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let s = s.to_lowercase();
        match s.as_str() {
            "off" => Ok(Self::new(Some(0x00))),
            "low" => Ok(Self::new(Some(0x01))),
            "med" => Ok(Self::new(Some(0x02))),
            "high" => Ok(Self::new(Some(0x03))),
            _ => Err(Error::ParseBrightness),
        }
    }
}

impl ToString for LedBrightness {
    fn to_string(&self) -> String {
        match self.level {
            Some(0x00) => "off".to_owned(),
            Some(0x01) => "low".to_owned(),
            Some(0x02) => "med".to_owned(),
            Some(0x03) => "high".to_owned(),
            _ => "unknown".to_owned(),
        }
    }
}

#[derive(FromArgs, Debug, Clone, Default)]
#[argh(
    subcommand,
    name = "keyboard",
    description = "set power states for keyboard zone"
)]
pub struct KeyboardPower {
    #[argh(switch, description = "defaults to false if option unused")]
    pub boot: bool,
    #[argh(switch, description = "defaults to false if option unused")]
    pub awake: bool,
    #[argh(switch, description = "defaults to false if option unused")]
    pub sleep: bool,
    #[argh(switch, description = "defaults to false if option unused")]
    pub shutdown: bool,
}

#[derive(FromArgs, Debug, Clone, Default)]
#[argh(
    subcommand,
    name = "logo",
    description = "set power states for logo zone"
)]
pub struct LogoPower {
    #[argh(switch, description = "defaults to false if option unused")]
    pub boot: bool,
    #[argh(switch, description = "defaults to false if option unused")]
    pub awake: bool,
    #[argh(switch, description = "defaults to false if option unused")]
    pub sleep: bool,
    #[argh(switch, description = "defaults to false if option unused")]
    pub shutdown: bool,
}

#[derive(FromArgs, Debug, Clone, Default)]
#[argh(
    subcommand,
    name = "lightbar",
    description = "set power states for lightbar zone"
)]
pub struct LightbarPower {
    #[argh(switch, description = "enable power while device is booting")]
    pub boot: bool,
    #[argh(switch, description = "enable power while device is awake")]
    pub awake: bool,
    #[argh(switch, description = "enable power while device is sleeping")]
    pub sleep: bool,
    #[argh(
        switch,
        description = "enable power while device is shutting down or hibernating"
    )]
    pub shutdown: bool,
}

#[derive(FromArgs, Debug, Clone, Default)]
#[argh(
    subcommand,
    name = "lid",
    description = "set power states for lid zone"
)]
pub struct LidPower {
    #[argh(switch, description = "defaults to false if option unused")]
    pub boot: bool,
    #[argh(switch, description = "defaults to false if option unused")]
    pub awake: bool,
    #[argh(switch, description = "defaults to false if option unused")]
    pub sleep: bool,
    #[argh(switch, description = "defaults to false if option unused")]
    pub shutdown: bool,
}

#[derive(FromArgs, Debug, Clone, Default)]
#[argh(
    subcommand,
    name = "rear-glow",
    description = "set power states for rear glow zone"
)]
pub struct RearGlowPower {
    #[argh(switch, description = "defaults to false if option unused")]
    pub boot: bool,
    #[argh(switch, description = "defaults to false if option unused")]
    pub awake: bool,
    #[argh(switch, description = "defaults to false if option unused")]
    pub sleep: bool,
    #[argh(switch, description = "defaults to false if option unused")]
    pub shutdown: bool,
}

#[derive(FromArgs, Debug, Clone, Default)]
#[argh(
    subcommand,
    name = "ally",
    description = "set power states for ally zone"
)]
pub struct AllyPower {
    #[argh(switch, description = "defaults to false if option unused")]
    pub boot: bool,
    #[argh(switch, description = "defaults to false if option unused")]
    pub awake: bool,
    #[argh(switch, description = "defaults to false if option unused")]
    pub sleep: bool,
    #[argh(switch, description = "defaults to false if option unused")]
    pub shutdown: bool,
}

/// Single speed-based effect
#[derive(FromArgs, Debug, Clone, Default)]
#[argh(
    subcommand,
    name = "rainbow-cycle",
    description = "single speed-based effect"
)]
pub struct SingleSpeed {
    #[argh(option, description = "set the speed: low, med, high")]
    pub speed: Speed,

    #[argh(
        option,
        description = "set the zone for this effect e.g. 0, 1, one, logo, lightbar-left"
    )]
    pub zone: AuraZone,
}

/// Single speed effect with direction
#[derive(FromArgs, Debug, Clone, Default)]
#[argh(
    subcommand,
    name = "rainbow-wave",
    description = "single speed effect with direction"
)]
pub struct SingleSpeedDirection {
    #[argh(option, description = "set the direction: up, down, left, right")]
    pub direction: Direction,

    #[argh(option, description = "set the speed: low, med, high")]
    pub speed: Speed,

    #[argh(
        option,
        description = "set the zone for this effect e.g. 0, 1, one, logo, lightbar-left"
    )]
    pub zone: AuraZone,
}

/// Static single-colour effect
#[derive(FromArgs, Debug, Clone, Default)]
#[argh(
    subcommand,
    name = "static",
    description = "static single-colour effect"
)]
pub struct SingleColour {
    #[argh(option, description = "set the RGB value e.g. ff00ff")]
    pub colour: Colour,

    #[argh(
        option,
        description = "set the zone for this effect e.g. 0, 1, one, logo, lightbar-left"
    )]
    pub zone: AuraZone,
}

/// Single-colour effect with speed
#[derive(FromArgs, Debug, Clone, Default)]
#[argh(
    subcommand,
    name = "highlight",
    description = "single-colour effect with speed"
)]
pub struct SingleColourSpeed {
    #[argh(option, description = "set the RGB value e.g. ff00ff")]
    pub colour: Colour,

    #[argh(option, description = "set the speed: low, med, high")]
    pub speed: Speed,

    #[argh(
        option,
        description = "set the zone for this effect e.g. 0, 1, one, logo, lightbar-left"
    )]
    pub zone: AuraZone,
}

/// Two-colour breathing effect
#[derive(FromArgs, Debug, Clone, Default)]
#[argh(
    subcommand,
    name = "breathe",
    description = "two-colour breathing effect"
)]
pub struct TwoColourSpeed {
    #[argh(option, description = "set the first RGB value e.g. ff00ff")]
    pub colour: Colour,

    #[argh(option, description = "set the second RGB value e.g. ff00ff")]
    pub colour2: Colour,

    #[argh(option, description = "set the speed: low, med, high")]
    pub speed: Speed,

    #[argh(
        option,
        description = "set the zone for this effect e.g. 0, 1, one, logo, lightbar-left"
    )]
    pub zone: AuraZone,
}

/// Multi-zone colour settings
#[derive(FromArgs, Debug, Clone, Default)]
#[allow(dead_code)]
#[argh(description = "multi-zone colour settings")]
pub struct MultiZone {
    #[argh(option, short = 'a', description = "set the RGB value e.g. ff00ff")]
    pub colour1: Colour,

    #[argh(option, short = 'b', description = "set the RGB value e.g. ff00ff")]
    pub colour2: Colour,

    #[argh(option, short = 'c', description = "set the RGB value e.g. ff00ff")]
    pub colour3: Colour,

    #[argh(option, short = 'd', description = "set the RGB value e.g. ff00ff")]
    pub colour4: Colour,
}

/// Multi-colour with speed
#[derive(FromArgs, Debug, Clone, Default)]
#[allow(dead_code)]
#[argh(description = "multi-colour with speed")]
pub struct MultiColourSpeed {
    #[argh(option, short = 'a', description = "set the RGB value e.g. ff00ff")]
    pub colour1: Colour,

    #[argh(option, short = 'b', description = "set the RGB value e.g. ff00ff")]
    pub colour2: Colour,

    #[argh(option, short = 'c', description = "set the RGB value e.g. ff00ff")]
    pub colour3: Colour,

    #[argh(option, short = 'd', description = "set the RGB value e.g. ff00ff")]
    pub colour4: Colour,

    #[argh(option, description = "set the speed: low, med, high")]
    pub speed: Speed,
}

/// Builtin aura effects
#[derive(FromArgs, Debug)]
#[argh(subcommand)]
pub enum SetAuraBuiltin {
    Static(SingleColour),              // 0
    Breathe(TwoColourSpeed),           // 1
    RainbowCycle(SingleSpeed),         // 2
    RainbowWave(SingleSpeedDirection), // 3
    Stars(TwoColourSpeed),             // 4
    Rain(SingleSpeed),                 // 5
    Highlight(SingleColourSpeed),      // 6
    Laser(SingleColourSpeed),          // 7
    Ripple(SingleColourSpeed),         // 8
    Pulse(SingleColour),               // 10
    Comet(SingleColour),               // 11
    Flash(SingleColour),               // 12
}

impl Default for SetAuraBuiltin {
    fn default() -> Self {
        SetAuraBuiltin::Static(SingleColour::default())
    }
}

impl From<&SingleColour> for AuraEffect {
    fn from(aura: &SingleColour) -> Self {
        Self {
            colour1: aura.colour,
            zone: aura.zone,
            ..Default::default()
        }
    }
}

impl From<&SingleSpeed> for AuraEffect {
    fn from(aura: &SingleSpeed) -> Self {
        Self {
            speed: aura.speed,
            zone: aura.zone,
            ..Default::default()
        }
    }
}

impl From<&SingleColourSpeed> for AuraEffect {
    fn from(aura: &SingleColourSpeed) -> Self {
        Self {
            colour1: aura.colour,
            speed: aura.speed,
            zone: aura.zone,
            ..Default::default()
        }
    }
}

impl From<&TwoColourSpeed> for AuraEffect {
    fn from(aura: &TwoColourSpeed) -> Self {
        Self {
            colour1: aura.colour,
            colour2: aura.colour2,
            zone: aura.zone,
            ..Default::default()
        }
    }
}

impl From<&SingleSpeedDirection> for AuraEffect {
    fn from(aura: &SingleSpeedDirection) -> Self {
        Self {
            speed: aura.speed,
            direction: aura.direction,
            zone: aura.zone,
            ..Default::default()
        }
    }
}

impl From<&SetAuraBuiltin> for AuraEffect {
    fn from(aura: &SetAuraBuiltin) -> Self {
        match aura {
            SetAuraBuiltin::Static(x) => {
                let mut data: AuraEffect = x.into();
                data.mode = AuraModeNum::Static;
                data
            }
            SetAuraBuiltin::Breathe(x) => {
                let mut data: AuraEffect = x.into();
                data.mode = AuraModeNum::Breathe;
                data
            }
            SetAuraBuiltin::RainbowCycle(x) => {
                let mut data: AuraEffect = x.into();
                data.mode = AuraModeNum::RainbowCycle;
                data
            }
            SetAuraBuiltin::RainbowWave(x) => {
                let mut data: AuraEffect = x.into();
                data.mode = AuraModeNum::RainbowWave;
                data
            }
            SetAuraBuiltin::Stars(x) => {
                let mut data: AuraEffect = x.into();
                data.mode = AuraModeNum::Star;
                data
            }
            SetAuraBuiltin::Rain(x) => {
                let mut data: AuraEffect = x.into();
                data.mode = AuraModeNum::Rain;
                data
            }
            SetAuraBuiltin::Highlight(x) => {
                let mut data: AuraEffect = x.into();
                data.mode = AuraModeNum::Highlight;
                data
            }
            SetAuraBuiltin::Laser(x) => {
                let mut data: AuraEffect = x.into();
                data.mode = AuraModeNum::Laser;
                data
            }
            SetAuraBuiltin::Ripple(x) => {
                let mut data: AuraEffect = x.into();
                data.mode = AuraModeNum::Ripple;
                data
            }
            SetAuraBuiltin::Pulse(x) => {
                let mut data: AuraEffect = x.into();
                data.mode = AuraModeNum::Pulse;
                data
            }
            SetAuraBuiltin::Comet(x) => {
                let mut data: AuraEffect = x.into();
                data.mode = AuraModeNum::Comet;
                data
            }
            SetAuraBuiltin::Flash(x) => {
                let mut data: AuraEffect = x.into();
                data.mode = AuraModeNum::Flash;
                data
            }
        }
    }
}
