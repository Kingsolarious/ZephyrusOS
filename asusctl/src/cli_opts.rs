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
    Info(InfoCommand),
}

#[derive(FromArgs, Debug)]
#[argh(subcommand, name = "profile", description = "profile management")]
pub struct ProfileCommand {
    #[argh(subcommand)]
    pub command: ProfileSubCommand,
}

#[derive(FromArgs, Debug)]
#[argh(subcommand)]
pub enum ProfileSubCommand {
    Next(ProfileNextCommand),
    List(ProfileListCommand),
    Get(ProfileGetCommand),
    Set(ProfileSetCommand),
}

impl Default for ProfileSubCommand {
    fn default() -> Self {
        ProfileSubCommand::List(ProfileListCommand::default())
    }
}

#[derive(FromArgs, Debug, Default)]
#[argh(
    subcommand,
    name = "next",
    description = "toggle to next profile in list"
)]
pub struct ProfileNextCommand {}

#[derive(FromArgs, Debug, Default)]
#[argh(subcommand, name = "list", description = "list available profiles")]
pub struct ProfileListCommand {}

#[derive(FromArgs, Debug, Default)]
#[argh(subcommand, name = "get", description = "get profile")]
pub struct ProfileGetCommand {}

#[derive(FromArgs, Debug, Default)]
#[argh(subcommand, name = "set", description = "set profile")]
pub struct ProfileSetCommand {
    #[argh(positional, description = "profile to set")]
    pub profile: PlatformProfile,

    #[argh(
        switch,
        short = 'a',
        description = "set the profile to use on AC power"
    )]
    pub ac: bool,

    #[argh(
        switch,
        short = 'b',
        description = "set the profile to use on battery power"
    )]
    pub battery: bool,
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
    #[argh(subcommand)]
    pub command: ArmourySubCommand,
}

#[derive(FromArgs, Debug)]
#[argh(subcommand)]
pub enum ArmourySubCommand {
    Set(ArmouryPropertySetCommand),
    Get(ArmouryPropertyGetCommand),
    List(ArmouryPropertyListCommand),
}

impl Default for ArmourySubCommand {
    fn default() -> Self {
        ArmourySubCommand::List(ArmouryPropertyListCommand::default())
    }
}

#[derive(FromArgs, Debug, Default)]
#[argh(
    subcommand,
    name = "set",
    description = "set an asus-armoury firmware-attribute"
)]
pub struct ArmouryPropertySetCommand {
    #[argh(
        positional,
        description = "name of the attribute to set (see asus-armoury list for available properties)"
    )]
    pub property: String,

    #[argh(positional, description = "value to set for the given attribute")]
    pub value: i32,
}

#[derive(FromArgs, Debug, Default)]
#[argh(
    subcommand,
    name = "list",
    description = "list all firmware-attributes supported by asus-armoury"
)]
pub struct ArmouryPropertyListCommand {}

#[derive(FromArgs, Debug, Default)]
#[argh(
    subcommand,
    name = "get",
    description = "get a firmware-attribute from asus-armoury"
)]
pub struct ArmouryPropertyGetCommand {
    #[argh(
        positional,
        description = "name of the property to get (see asus-armoury list for available properties)"
    )]
    pub property: String,
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

#[derive(FromArgs, Debug, Default)]
#[argh(
    subcommand,
    name = "info",
    description = "show program version and system info"
)]
pub struct InfoCommand {}
