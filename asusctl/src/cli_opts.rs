use argh::FromArgs;
use rog_platform::platform::PlatformProfile;

use crate::anime_cli::AnimeCommand;
use crate::aura_cli::{LedBrightness, LedPowerCommand1, LedPowerCommand2, SetAuraBuiltin};
use crate::fan_curve_cli::FanCurveCommand;
use crate::scsi_cli::ScsiCommand;
use crate::slash_cli::SlashCommand;

#[derive(FromArgs, Default, Debug)]
/// asusctl command-line options
pub struct CliStart {
    #[argh(switch, description = "show program version number")]
    pub version: bool,

    #[argh(switch, description = "show supported functions of this laptop")]
    pub show_supported: bool,

    #[argh(option, description = "keyboard brightness <off, low, med, high>")]
    pub kbd_bright: Option<LedBrightness>,

    #[argh(switch, description = "toggle to next keyboard brightness")]
    pub next_kbd_bright: bool,

    #[argh(switch, description = "toggle to previous keyboard brightness")]
    pub prev_kbd_bright: bool,

    #[argh(option, description = "set your battery charge limit <20-100>")]
    pub chg_limit: Option<u8>,

    #[argh(switch, description = "toggle one-shot battery charge to 100%")]
    pub one_shot_chg: bool,

    #[argh(subcommand)]
    pub command: Option<CliCommand>,
}

/// Top-level subcommands for asusctl
#[derive(FromArgs, Debug)]
#[argh(subcommand)]
pub enum CliCommand {
    Aura(LedModeCommand),
    AuraPowerOld(LedPowerCommand1),
    AuraPower(LedPowerCommand2),
    Profile(ProfileCommand),
    FanCurve(FanCurveCommand),
    Anime(AnimeCommand),
    Slash(SlashCommand),
    Scsi(ScsiCommand),
    Armoury(ArmouryCommand),
    Backlight(BacklightCommand),
}

#[derive(FromArgs, Debug, Clone, Default)]
#[argh(subcommand, name = "profile", description = "profile management")]
pub struct ProfileCommand {
    #[argh(switch, description = "toggle to next profile in list")]
    pub next: bool,

    #[argh(switch, description = "list available profiles")]
    pub list: bool,

    #[argh(switch, description = "get profile")]
    pub profile_get: bool,

    #[argh(option, description = "set the active profile")]
    pub profile_set: Option<PlatformProfile>,

    #[argh(
        option,
        short = 'a',
        description = "set the profile to use on AC power"
    )]
    pub profile_set_ac: Option<PlatformProfile>,

    #[argh(
        option,
        short = 'b',
        description = "set the profile to use on battery power"
    )]
    pub profile_set_bat: Option<PlatformProfile>,
}

#[derive(FromArgs, Debug, Default)]
#[argh(subcommand, name = "aura", description = "led mode commands")]
pub struct LedModeCommand {
    #[argh(switch, description = "switch to next aura mode")]
    pub next_mode: bool,

    #[argh(switch, description = "switch to previous aura mode")]
    pub prev_mode: bool,

    #[argh(subcommand)]
    pub command: Option<SetAuraBuiltin>,
}

#[derive(FromArgs, Debug, Default)]
#[argh(
    subcommand,
    name = "armoury",
    description = "armoury / firmware attributes"
)]
pub struct ArmouryCommand {
    #[argh(
        positional,
        description = "append each value name followed by the value to set. `-1` sets to default"
    )]
    pub free: Vec<String>,
}

#[derive(FromArgs, Debug, Default)]
#[argh(subcommand, name = "backlight", description = "backlight options")]
pub struct BacklightCommand {
    #[argh(option, description = "set screen brightness <0-100>")]
    pub screenpad_brightness: Option<i32>,

    #[argh(
        option,
        description = "set screenpad gamma brightness 0.5 - 2.2, 1.0 == linear"
    )]
    pub screenpad_gamma: Option<f32>,

    #[argh(
        option,
        description = "set screenpad brightness to sync with primary display"
    )]
    pub sync_screenpad_brightness: Option<bool>,
}
