# Neovim Office

This project aims provide some basic functionality for _office_ management.

 - [x] (WIP) Basic File Browsing
 - [x] (WIP) Email
 - [ ] Calendar
 - [ ] Contact Management

Maybe in the future, some tabular data management,

## Basic File Browsing

This was the first step because with this particular plug-in I started working out the way to _connect_ different _buffers_ and _windows_, to work together.

## Email

Mail management is done using `maildir` and `mblaze`, so make sure your have that installed.

The general idea is to have 3 different types of buffers, _boxes view_, _list view_ and _preview_.

So far the _boxes_view_, renders a _tree_ with the names of all the boxes and indenting the _sub  boxes_.

All _list views_ should have a `conceal` value from `/^/` to `/\t,/` that indicates the message file this row is representing.

The variable `g:MBlazeChannelsDir` is defaulted to `$HOME/.cache/mail`, this should point to a directory where you have all your _channels_ stored.

> This is working with `isync` to synchronize mailboxes, but the part that actually concerns the plug-in is just the _maildir_ management, not the actual synchronization.


### TODO

 - Add namespace to include virtual text on _boxes view_.
 - Include the ability to apply filters on _list view_
 - Options to render the _email content_


## Calendar

> Pending

## Contact Management

> Pending

# General To do

 - [ ] Write Documentation
 - [ ] Re-factor to `filetypes`
 - [ ] Include `vader` testing

# Install

You should clone this under your `pack` directory, and then execute the `packadd` statement with the corresponding directory name, to include the plug-in.

## Mail Configuration

> Sending Mail still pending

This plug-in is though to work with `isync`/`mbsync` `Maildir` directories.

> It should work with another mail synchronization program that stores your 
> email as `Maildir`.

Once you have the `Maildir` directory structure, make sure you have installed [`mblaze`](https://github.com/leahneukirchen/mblaze).

By default this plug-in will look for your mail at `~/.cache/mail` (If your email is at another place you can overwrite the variable `g:mail_directory` with the path to a `Maildir` directory).

The command `MailBoxes` will toggle a window created at `topleft` (left side of the screen), with a _tree_ of all your _maildir directories_, you can navigate as usual,
with `jk`, except that `hl` will move you the next window that direction, you select
a directory with `<cr>`, and it will get a window to display the corresponding list
of mail.

Alternative you can execute the command `MailBox` with the _relative path_ to the target _maildir_ from `g:mail_directory`.

While navigating a mail list navigation is the same as in the window for `MailBoxes`.
Opening an _email_ is done by pressing `<cr>`.

> Pending mappings to action over email in list.

While navigating a `MailBox` window, you can set a _date range_ to filter the list with the command `MailListDateRange`, with **no** arguments it will _reset_ the date filter, with **one** argument will use it as _lower bound_, with **two** it will use it the first as _lower_ the second as _upper_ when comparing the date.

You can open a message by selecting in a list.

> Pending mappings to action over message files.

# Questions for users

 - Is this in it's current state compatible with regular `vim`?
 - Are there serious benefits of rewriting this in `lua`?
 - Is there another `email` plugin I should be looking at for inspiration?

