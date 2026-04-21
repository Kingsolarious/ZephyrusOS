/*
 * Zephyrus GTK Menu Exporter
 * 
 * Compile with:
 * gcc -shared -fPIC -o zephyrus-gtk-menu.so gtk-menu-exporter.c `pkg-config --cflags --libs gtk4`
 * 
 * Use with:
 * LD_PRELOAD=/path/to/zephyrus-gtk-menu.so firefox
 */

#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dbus/dbus.h>
#include <gtk/gtk.h>

static DBusConnection *dbus_conn = NULL;
static char app_id[256] = {0};

// Initialize D-Bus connection
static void init_dbus() {
    if (dbus_conn) return;
    
    DBusError err;
    dbus_error_init(&err);
    
    dbus_conn = dbus_bus_get(DBUS_BUS_SESSION, &err);
    if (dbus_error_is_set(&err)) {
        fprintf(stderr, "Zephyrus Menu: D-Bus error: %s\n", err.message);
        dbus_error_free(&err);
        return;
    }
    
    // Get app ID from environment or process name
    const char *env_id = getenv("ZEPHYRUS_APP_ID");
    if (env_id) {
        strncpy(app_id, env_id, sizeof(app_id) - 1);
    } else {
        // Use process name
        snprintf(app_id, sizeof(app_id), "app-%d", getpid());
    }
    
    printf("Zephyrus Menu: Initialized for %s\n", app_id);
}

// Send menu to service
static void send_menu_to_service(const char *menu_json) {
    if (!dbus_conn) return;
    
    DBusMessage *msg = dbus_message_new_method_call(
        "org.zephyrus.MenuService",
        "/org/zephyrus/MenuService",
        "org.zephyrus.MenuInterface",
        "RegisterMenu"
    );
    
    if (!msg) return;
    
    dbus_message_append_args(msg,
        DBUS_TYPE_STRING, &app_id,
        DBUS_TYPE_STRING, &menu_json,
        DBUS_TYPE_INVALID
    );
    
    dbus_connection_send(dbus_conn, msg, NULL);
    dbus_message_unref(msg);
    dbus_connection_flush(dbus_conn);
}

// Convert GTK menu to JSON
static char *menu_to_json(GtkApplication *app) {
    GString *json = g_string_new("{\"menus\":[");
    
    // Get menu model from app
    GMenuModel *menu = gtk_application_get_menubar(app);
    if (!menu) {
        g_string_append(json, "],\"items\":[]}");
        return g_string_free(json, FALSE);
    }
    
    // Iterate through menu sections
    int n_sections = g_menu_model_get_n_items(menu);
    for (int i = 0; i < n_sections; i++) {
        GMenuModel *section = g_menu_model_get_item_link(menu, i, G_MENU_LINK_SECTION);
        if (!section) continue;
        
        // Get section items
        int n_items = g_menu_model_get_n_items(section);
        for (int j = 0; j < n_items; j++) {
            char *label = NULL;
            g_menu_model_get_item_attribute(section, j, G_MENU_ATTRIBUTE_LABEL, "s", &label);
            
            if (label) {
                if (i > 0 || j > 0) g_string_append(json, ",");
                g_string_append_printf(json, "{\"label\":\"%s\",\"path\":\"%d.%d\"}",
                    label, i, j);
                g_free(label);
            }
        }
        
        g_object_unref(section);
    }
    
    g_string_append(json, "]}");
    return g_string_free(json, FALSE);
}

// Hook into gtk_application_set_menubar
typedef void (*orig_set_menubar_t)(GtkApplication *app, GMenuModel *menubar);
static orig_set_menubar_t orig_set_menubar = NULL;

void gtk_application_set_menubar(GtkApplication *app, GMenuModel *menubar) {
    if (!orig_set_menubar) {
        orig_set_menubar = dlsym(RTLD_NEXT, "gtk_application_set_menubar");
    }
    
    // Call original
    orig_set_menubar(app, menubar);
    
    // Initialize D-Bus
    init_dbus();
    
    // Export menu
    if (menubar) {
        char *json = menu_to_json(app);
        send_menu_to_service(json);
        g_free(json);
        
        printf("Zephyrus Menu: Exported menu for %s\n", app_id);
    }
}

// Constructor
__attribute__((constructor))
static void init() {
    printf("Zephyrus Menu: GTK Module loaded\n");
}

// Destructor
__attribute__((destructor))
static void cleanup() {
    if (dbus_conn) {
        // Unregister menu
        DBusMessage *msg = dbus_message_new_method_call(
            "org.zephyrus.MenuService",
            "/org/zephyrus/MenuService",
            "org.zephyrus.MenuInterface",
            "UnregisterMenu"
        );
        
        if (msg) {
            dbus_message_append_args(msg, DBUS_TYPE_STRING, &app_id, DBUS_TYPE_INVALID);
            dbus_connection_send(dbus_conn, msg, NULL);
            dbus_message_unref(msg);
        }
        
        dbus_connection_unref(dbus_conn);
    }
    
    printf("Zephyrus Menu: GTK Module unloaded\n");
}
