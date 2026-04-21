// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * Simple HID driver for ASUS ROG Slash LED (193b)
 */

#include <linux/module.h>
#include <linux/hid.h>
#include <linux/leds.h>

#define USB_VENDOR_ID_ASUSTEK 0x0b05
#define USB_DEVICE_ID_ASUSTEK_ROG_SLASH_GU605 0x193b

#define REPORT_ID 0x5d
#define CMD_LED 0xbc

static const struct hid_device_id asus_slash_devices[] = {
    { HID_USB_DEVICE(USB_VENDOR_ID_ASUSTEK, USB_DEVICE_ID_ASUSTEK_ROG_SLASH_GU605) },
    { }
};
MODULE_DEVICE_TABLE(hid, asus_slash_devices);

struct asus_slash_data {
    struct hid_device *hdev;
    struct led_classdev led_cdev;
    u8 brightness;
    u8 mode;
    u8 enabled;
};

static int asus_slash_send_command(struct asus_slash_data *data)
{
    u8 cmd[16] = {
        REPORT_ID, CMD_LED,
        data->enabled, data->mode,
        data->brightness, 1,  // interval
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    };
    
    return hid_hw_output_report(data->hdev, cmd, sizeof(cmd));
}

static void asus_slash_led_set(struct led_classdev *led_cdev,
                               enum led_brightness brightness)
{
    struct asus_slash_data *data = container_of(led_cdev, struct asus_slash_data, led_cdev);
    
    data->brightness = brightness;
    data->enabled = brightness > 0 ? 1 : 0;
    
    asus_slash_send_command(data);
}

static int asus_slash_probe(struct hid_device *hdev, const struct hid_device_id *id)
{
    struct asus_slash_data *data;
    int ret;
    
    data = devm_kzalloc(&hdev->dev, sizeof(*data), GFP_KERNEL);
    if (!data)
        return -ENOMEM;
    
    data->hdev = hdev;
    data->brightness = 200;
    data->mode = 7;  // Flux
    data->enabled = 1;
    
    hid_set_drvdata(hdev, data);
    
    ret = hid_parse(hdev);
    if (ret) {
        hid_err(hdev, "parse failed\n");
        return ret;
    }
    
    ret = hid_hw_start(hdev, HID_CONNECT_DEFAULT);
    if (ret) {
        hid_err(hdev, "hw start failed\n");
        return ret;
    }
    
    // Register LED device
    data->led_cdev.name = "asus::slash";
    data->led_cdev.max_brightness = 255;
    data->led_cdev.brightness_set = asus_slash_led_set;
    
    ret = devm_led_classdev_register(&hdev->dev, &data->led_cdev);
    if (ret) {
        hid_err(hdev, "led registration failed\n");
        hid_hw_stop(hdev);
        return ret;
    }
    
    // Send initial command
    asus_slash_send_command(data);
    
    hid_info(hdev, "ASUS ROG Slash LED (193b) driver loaded\n");
    return 0;
}

static void asus_slash_remove(struct hid_device *hdev)
{
    hid_hw_stop(hdev);
}

static struct hid_driver asus_slash_driver = {
    .name = "asus-slash",
    .id_table = asus_slash_devices,
    .probe = asus_slash_probe,
    .remove = asus_slash_remove,
};
module_hid_driver(asus_slash_driver);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Zephyrus OS");
MODULE_DESCRIPTION("ASUS ROG Slash LED driver for GU605MY");
