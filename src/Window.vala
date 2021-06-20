/* Window.vala
 *
 * Copyright 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


namespace TextPieces {

    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/Window.ui")]
    public class Window : Adw.ApplicationWindow {

        [GtkChild]
        unowned Gtk.ListBox search_listbox;
        [GtkChild]
        unowned Gtk.SearchEntry search_entry;
        [GtkChild]
        unowned Gtk.EventControllerKey search_event_controller;
        [GtkChild]
        unowned Gtk.Stack search_stack;

        Gtk.FilterListModel search_list;

        private const ActionEntry[] ACTION_ENTRIES = {
            { "apply", action_apply },
            { "preferences", action_preferences },
            { "about", action_about },
            { "copy", action_copy }
        };

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            // Load actions
            add_action_entries (ACTION_ENTRIES, this);

            // Set help overlay
            var builder = new Gtk.Builder.from_resource ("/com/github/liferooter/textpieces/ui/ShortcutsWindow.ui");
            var overlay = (Gtk.ShortcutsWindow) builder.get_object ("overlay");
            set_help_overlay (overlay);

            search_list = get_tools (this);

            search_listbox.bind_model (
                search_list,
                build_list_row
            );
        }

        void action_apply () {
            // Not Implemented Yet
            message ("ACTION APPLY");
        }

        void action_preferences () {
            var prefs = new Preferences () {
                transient_for =  this
            };
            prefs.present ();
        }

        void action_about () {
            // Not Implemented Yet
            message ("ACTION ABOUT");
        }

        void action_copy () {
            // Not Implemented Yet
            message ("ACTION COPY");
        }

        public bool tool_filter_func (Object item) {
            var tool = (Tool) item;

            var name = tool.name.casefold ();
            var description = tool.description.casefold ();
            var terms = search_entry.text.casefold ().split (" ");

            var min_name = 0;
            var min_desc = 0;
            int match;

            foreach (var term in terms) {
                if ((match = description.index_of (term, min_desc)) != -1)
                    min_desc = match + term.length;
                else if ((match = name.index_of (term, min_name)) != -1)
                    min_name = match + term.length;
                else
                    return false;
            }

            return true;
        }

        [GtkCallback]
        string get_page_name (bool search_enabled) {
            if (search_enabled) {
                return "search";
            } else {
                return "editor";
            }
        }

        [GtkCallback]
        void on_search_changed () {
            search_list.filter.changed (Gtk.FilterChange.DIFFERENT);
            search_stack.set_visible_child_name (search_list.get_n_items () == 0 ? "placeholder" : "search");
        }

        [GtkCallback]
        bool on_search_entry_key (uint keyval, uint keycode, Gdk.ModifierType state) {
            if (keyval == Gdk.Key.Down) {
                var first_row = search_listbox.get_row_at_index (0);
                if (first_row != null) {
                    ((!) first_row).grab_focus ();
                    return true;
                }
            }
            return false;
        }

        [GtkCallback]
        bool on_search_listbox_key (uint keyval, uint keycode, Gdk.ModifierType state) {
            if (keyval == Gdk.Key.Up) {
                var focus = this.focus_widget;
                if (focus.get_type () == typeof (Adw.ActionRow) && ((Adw.ActionRow) focus).get_index () == 0) {
                    search_entry.grab_focus ();
                    return true;
                }
            }
            return false;
        }

        [GtkCallback]
        void on_row_activated (Gtk.ListBoxRow row) {
            message ("ROW ACTIVATED: %s", ((Adw.ActionRow) row).title);
        }
    }
}
