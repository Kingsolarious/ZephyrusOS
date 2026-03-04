use std::sync::{Arc, Mutex};

use log::{debug, error, info};
use rog_dbus::zbus_slash::SlashProxy;
use rog_slash::SlashMode;
use slint::ComponentHandle;

use crate::config::Config;
use crate::ui::show_toast;
use crate::{set_ui_callbacks, set_ui_props_async, MainWindow, SlashPageData};

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
                let mode = match mode_idx {
                    0 => SlashMode::Static,
                    1 => SlashMode::Bounce,
                    2 => SlashMode::Slash,
                    3 => SlashMode::Loading,
                    4 => SlashMode::BitStream,
                    5 => SlashMode::Transmission,
                    6 => SlashMode::Flow,
                    7 => SlashMode::Flux,
                    8 => SlashMode::Phantom,
                    9 => SlashMode::Spectrum,
                    10 => SlashMode::Hazard,
                    11 => SlashMode::Interfacing,
                    12 => SlashMode::Ramp,
                    13 => SlashMode::GameOver,
                    14 => SlashMode::Start,
                    15 => SlashMode::Buzzer,
                    _ => SlashMode::Spectrum,
                };
                let p = proxy_copy.clone();
                let w = weak_copy.clone();
                tokio::spawn(async move {
                    show_toast(
                        "Slash mode updated".into(),
                        "Failed to set Slash mode".into(),
                        w,
                        p.set_mode(mode).await,
                    );
                });
            });
        }).ok();

        // Load current mode
        if let Ok(mode) = slash.mode().await {
            let mode_idx = match mode {
                SlashMode::Static => 0,
                SlashMode::Bounce => 1,
                SlashMode::Slash => 2,
                SlashMode::Loading => 3,
                SlashMode::BitStream => 4,
                SlashMode::Transmission => 5,
                SlashMode::Flow => 6,
                SlashMode::Flux => 7,
                SlashMode::Phantom => 8,
                SlashMode::Spectrum => 9,
                SlashMode::Hazard => 10,
                SlashMode::Interfacing => 11,
                SlashMode::Ramp => 12,
                SlashMode::GameOver => 13,
                SlashMode::Start => 14,
                SlashMode::Buzzer => 15,
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
        
        handle.upgrade_in_event_loop(move |h| {
            h.global::<SlashPageData>().set_show_on_boot(show_boot);
            h.global::<SlashPageData>().set_show_on_shutdown(show_shutdown);
            h.global::<SlashPageData>().set_show_on_sleep(show_sleep);
            h.global::<SlashPageData>().set_show_on_battery(show_battery);
            h.global::<SlashPageData>().set_show_battery_warning(show_battery_warn);
        }).ok();

        // Mode change stream
        let stream_handle = handle.clone();
        let slash_stream = slash.clone();
        tokio::spawn(async move {
            use futures_util::StreamExt;
            let mut stream = slash_stream.receive_mode_changed().await;
            while let Some(e) = stream.next().await {
                if let Ok(mode) = e.get().await {
                    let mode_idx = match mode {
                        SlashMode::Static => 0,
                        SlashMode::Bounce => 1,
                        SlashMode::Slash => 2,
                        SlashMode::Loading => 3,
                        SlashMode::BitStream => 4,
                        SlashMode::Transmission => 5,
                        SlashMode::Flow => 6,
                        SlashMode::Flux => 7,
                        SlashMode::Phantom => 8,
                        SlashMode::Spectrum => 9,
                        SlashMode::Hazard => 10,
                        SlashMode::Interfacing => 11,
                        SlashMode::Ramp => 12,
                        SlashMode::GameOver => 13,
                        SlashMode::Start => 14,
                        SlashMode::Buzzer => 15,
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
