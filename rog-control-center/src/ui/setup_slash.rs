use std::sync::{Arc, Mutex};

use log::{debug, info};
use rog_dbus::zbus_slash::SlashProxy;
use rog_slash::SlashMode;
use slint::ComponentHandle;

use crate::config::Config;
use crate::ui::show_toast;
use crate::{set_ui_props_async, MainWindow, SlashPageData};

async fn find_slash_iface() -> Result<SlashProxy<'static>, Box<dyn std::error::Error>> {
    let conn = zbus::Connection::system().await?;
    SlashProxy::builder(&conn)
        .destination("xyz.ljones.Asusd")?
        .path("/xyz/ljones/aura/193b_4_8")?
        .build()
        .await
        .map_err(Into::into)
}

pub fn setup_slash_page(ui: &MainWindow, _states: Arc<Mutex<Config>>) {
    let handle = ui.as_weak();
    tokio::spawn(async move {
        let Ok(slash) = find_slash_iface().await else {
            info!("No Slash interface found");
            return Ok::<(), zbus::Error>(());
        };

        info!("Setting up Slash page");

        // Load initial values from D-Bus to UI
        set_ui_props_async!(handle, slash, SlashPageData, enabled);
        
        // Load brightness
        if let Ok(value) = slash.brightness().await {
            handle.upgrade_in_event_loop(move |h| {
                h.global::<SlashPageData>().set_brightness(value as i32);
            }).ok();
        }
        
        // Load interval
        if let Ok(value) = slash.interval().await {
            handle.upgrade_in_event_loop(move |h| {
                h.global::<SlashPageData>().set_interval(value as i32);
            }).ok();
        }

        // Set up callback for enabled
        let proxy = slash.clone();
        let weak = handle.clone();
        handle.upgrade_in_event_loop(move |h| {
            let proxy_copy = proxy.clone();
            let weak_copy = weak.clone();
            h.global::<SlashPageData>().on_cb_enabled(move |enabled| {
                let p = proxy_copy.clone();
                let w = weak_copy.clone();
                tokio::spawn(async move {
                    show_toast(
                        "Slash LED updated".into(),
                        "Failed to update Slash".into(),
                        w,
                        p.set_enabled(enabled).await,
                    );
                });
            });
        }).ok();

        // Set up callback for brightness
        let proxy = slash.clone();
        let weak = handle.clone();
        handle.upgrade_in_event_loop(move |h| {
            let proxy_copy = proxy.clone();
            let weak_copy = weak.clone();
            h.global::<SlashPageData>().on_cb_brightness(move |brightness| {
                let p = proxy_copy.clone();
                let w = weak_copy.clone();
                tokio::spawn(async move {
                    show_toast(
                        "Slash brightness updated".into(),
                        "Failed to update brightness".into(),
                        w,
                        p.set_brightness(brightness as u8).await,
                    );
                });
            });
        }).ok();

        // Set up callback for interval
        let proxy = slash.clone();
        let weak = handle.clone();
        handle.upgrade_in_event_loop(move |h| {
            let proxy_copy = proxy.clone();
            let weak_copy = weak.clone();
            h.global::<SlashPageData>().on_cb_interval(move |interval| {
                let p = proxy_copy.clone();
                let w = weak_copy.clone();
                tokio::spawn(async move {
                    show_toast(
                        "Slash speed updated".into(),
                        "Failed to update speed".into(),
                        w,
                        p.set_interval(interval as u8).await,
                    );
                });
            });
        }).ok();
        
        // Mode callback
        let proxy = slash.clone();
        let weak = handle.clone();
        handle.upgrade_in_event_loop(move |h| {
            let proxy_copy = proxy.clone();
            let weak_copy = weak.clone();
            h.global::<SlashPageData>().on_cb_mode(move |mode_idx| {
                let mode_u8 = match mode_idx {
                    0 => SlashMode::Static as u8,
                    1 => SlashMode::Bounce as u8,
                    2 => SlashMode::Slash as u8,
                    3 => SlashMode::Loading as u8,
                    4 => SlashMode::BitStream as u8,
                    5 => SlashMode::Transmission as u8,
                    6 => SlashMode::Flow as u8,
                    7 => SlashMode::Flux as u8,
                    8 => SlashMode::Phantom as u8,
                    9 => SlashMode::Spectrum as u8,
                    10 => SlashMode::Hazard as u8,
                    11 => SlashMode::Interfacing as u8,
                    12 => SlashMode::Ramp as u8,
                    13 => SlashMode::GameOver as u8,
                    14 => SlashMode::Start as u8,
                    15 => SlashMode::Buzzer as u8,
                    _ => SlashMode::Spectrum as u8,
                };
                let p = proxy_copy.clone();
                let w = weak_copy.clone();
                tokio::spawn(async move {
                    show_toast(
                        "Slash mode updated".into(),
                        "Failed to set Slash mode".into(),
                        w,
                        p.set_mode(mode_u8).await,
                    );
                });
            });
        }).ok();

        // Load current mode
        if let Ok(mode_u8) = slash.mode().await {
            let mode_idx = match mode_u8 {
                0x06 => 0,   // Static
                0x10 => 1,   // Bounce
                0x12 => 2,   // Slash
                0x13 => 3,   // Loading
                0x1d => 4,   // BitStream
                0x1a => 5,   // Transmission
                0x19 => 6,   // Flow
                0x25 => 7,   // Flux
                0x24 => 8,   // Phantom
                0x26 => 9,   // Spectrum
                0x32 => 10,  // Hazard
                0x33 => 11,  // Interfacing
                0x34 => 12,  // Ramp
                0x42 => 13,  // GameOver
                0x43 => 14,  // Start
                0x44 => 15,  // Buzzer
                _ => 9,      // Spectrum default
            };
            handle.upgrade_in_event_loop(move |h| {
                h.global::<SlashPageData>().set_current_mode(mode_idx);
            }).ok();
        }

        // Show options callback
        let proxy = slash.clone();
        let weak = handle.clone();
        handle.upgrade_in_event_loop(move |h| {
            let proxy_copy = proxy.clone();
            let weak_copy = weak.clone();
            h.global::<SlashPageData>().on_cb_show_options(move |options| {
                let p = proxy_copy.clone();
                let w = weak_copy.clone();
                tokio::spawn(async move {
                    let _ = p.set_show_on_boot(options.boot).await;
                    let _ = p.set_show_on_shutdown(options.shutdown).await;
                    let _ = p.set_show_on_sleep(options.sleep).await;
                    let _ = p.set_show_on_battery(options.battery).await;
                    let _ = p.set_show_battery_warning(options.battery_warning).await;
                    let _ = p.set_show_on_lid_closed(options.lid_closed).await;
                    show_toast(
                        "Slash options updated".into(),
                        "Failed to update options".into(),
                        w,
                        Ok(()),
                    );
                });
            });
        }).ok();

        // Load show options
        let show_boot = slash.show_on_boot().await.unwrap_or(true);
        let show_shutdown = slash.show_on_shutdown().await.unwrap_or(true);
        let show_sleep = slash.show_on_sleep().await.unwrap_or(true);
        let show_battery = slash.show_on_battery().await.unwrap_or(true);
        let show_battery_warn = slash.show_battery_warning().await.unwrap_or(true);
        let show_lid_closed = slash.show_on_lid_closed().await.unwrap_or(false);
        
        handle.upgrade_in_event_loop(move |h| {
            h.global::<SlashPageData>().set_show_on_boot(show_boot);
            h.global::<SlashPageData>().set_show_on_shutdown(show_shutdown);
            h.global::<SlashPageData>().set_show_on_sleep(show_sleep);
            h.global::<SlashPageData>().set_show_on_battery(show_battery);
            h.global::<SlashPageData>().set_show_battery_warning(show_battery_warn);
            h.global::<SlashPageData>().set_show_on_lid_closed(show_lid_closed);
        }).ok();

        // Mode change stream

        // Custom animation callback (load .slashlighting file via kdialog)
        let weak_custom = handle.clone();
        handle.upgrade_in_event_loop(move |h| {
            h.global::<SlashPageData>().on_cb_custom_animation(move || {
                let w = weak_custom.clone();
                tokio::spawn(async move {
                    let output = std::process::Command::new("kdialog")
                        .args(["--getopenfilename", "/usr/share/zephyrus-os/slash-animations", "*.slashlighting"])
                        .output();
                    if let Ok(out) = output {
                        let path = String::from_utf8_lossy(&out.stdout).trim().to_string();
                        if !path.is_empty() {
                            let _ = std::process::Command::new("/usr/local/bin/gu605my-slash-player")
                                .args(["--loop", &path])
                                .spawn();
                            let name = std::path::Path::new(&path)
                                .file_name()
                                .map(|n| n.to_string_lossy().to_string())
                                .unwrap_or_else(|| "animation".into());
                            show_toast(format!("Playing {}", name).into(), "Failed to play animation".into(), w, Ok(()));
                        }
                    }
                });
            });
        }).ok();
        let stream_handle = handle.clone();
        let slash_stream = slash.clone();
        tokio::spawn(async move {
            use futures_util::StreamExt;
            let mut stream = slash_stream.receive_mode_changed().await;
            while let Some(e) = stream.next().await {
                if let Ok(mode_u8) = e.get().await {
                    let mode_idx = match mode_u8 {
                        0x06 => 0,   // Static
                        0x10 => 1,   // Bounce
                        0x12 => 2,   // Slash
                        0x13 => 3,   // Loading
                        0x1d => 4,   // BitStream
                        0x1a => 5,   // Transmission
                        0x19 => 6,   // Flow
                        0x25 => 7,   // Flux
                        0x24 => 8,   // Phantom
                        0x26 => 9,   // Spectrum
                        0x32 => 10,  // Hazard
                        0x33 => 11,  // Interfacing
                        0x34 => 12,  // Ramp
                        0x42 => 13,  // GameOver
                        0x43 => 14,  // Start
                        0x44 => 15,  // Buzzer
                        _ => 9,      // Spectrum default
                    };
                    stream_handle.upgrade_in_event_loop(move |h| {
                        h.global::<SlashPageData>().set_current_mode(mode_idx);
                    }).ok();
                }
            }
        });

        debug!("Slash setup done");
        Ok(())
    });
}
