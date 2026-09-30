-- ~/.config/yazi/init.lua

-- try require the plugin safely (prévenir crash si le plugin n'est pas installé)
local ok, mount = pcall(require, "mount")
if ok and type(mount.setup) == "function" then
  mount.setup({
    -- options example (les options dépendent du plugin ; voir README local du plugin)
    auto_refresh = true,
    show_current = true,
  })
end

 require("full-border"):setup {
  type = ui.Border.ROUNDED,
  }

require("what-size"):setup({
    priority = 400,
    LEFT = "",
    RIGHT = " ",
})

require("recycle-bin"):setup()


local bookmarks = {
  { tag = "Documents", path = "~/Documents", key = "D" },
  { tag = "Downloads", path = "~/Downloads", key = "d" },
  { tag = "Pictures", path = "~/Pictures", key = "p" },
  { tag = "Music", path = "~/Music", key = "m" },
  { tag = "Videos", path = "~/Videos", key = "v" },
  { tag = "Home", path = "~/", key = "h" },
  { tag = ".config", path = "~/.config", key = "c" },
  { tag = "root", path = "/", key = "r" },
  { tag = "Mounts", path = "/run/media/gap", key = "M" },
  {tag = "Fac", path = "~/Documents/fac", key = "f"},
  {tag = "Dots", path = "~/.dotfiles", key = "F"}
}

require("whoosh"):setup {
  -- Configuration bookmarks (cannot be deleted through plugin)
  bookmarks = bookmarks,

  -- Notification settings
  jump_notify = false,

  -- Key generation for auto-assigning bookmark keys
  keys = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",

  -- Configure the built-in menu action hotkeys
  -- false - hide menu item
  special_keys = {
    create_temp = "<Enter>",         -- Create a temporary bookmark from the menu
    fuzzy_search = "<Space>",        -- Launch fuzzy search (fzf)
    history = "<Tab>",               -- Open directory history
    previous_dir = "<Backspace>",    -- Jump back to the previous directory
  },

  -- File path for storing user bookmarks
  bookmarks_path = (os.getenv("HOME") .. "/.config/yazi/plugins/whoosh.yazi/bookmarks"),

  -- Replace home directory with "~"
  home_alias_enabled = true,                            -- Toggle home aliasing in displays

  -- Path truncation in navigation menu
  path_truncate_enabled = false,                        -- Enable/disable path truncation
  path_max_depth = 3,                                   -- Maximum path depth before truncation

  -- Path truncation in fuzzy search (fzf)
  fzf_path_truncate_enabled = false,                    -- Enable/disable path truncation in fzf
  fzf_path_max_depth = 5,                               -- Maximum path depth before truncation in fzf

  -- Long folder name truncation
  path_truncate_long_names_enabled = false,             -- Enable in navigation menu
  fzf_path_truncate_long_names_enabled = false,         -- Enable in fzf
  path_max_folder_name_length = 20,                     -- Max length in navigation menu
  fzf_path_max_folder_name_length = 20,                 -- Max length in fzf

  -- History directory settings
  history_size = 10,                                    -- Number of directories in history (default 10)
  history_fzf_path_truncate_enabled = false,            -- Enable/disable path truncation by depth for history
  history_fzf_path_max_depth = 5,                       -- Maximum path depth before truncation for history (default 5)
  history_fzf_path_truncate_long_names_enabled = false, -- Enable/disable long folder name truncation for history
  history_fzf_path_max_folder_name_length = 30,         -- Maximum length for folder names in history (default 30)
}
