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


### TODO

 - Add namespace to include virtual text on _boxes view_.
 - Include the ability to apply filters on _list view_
 - Options to render the _email content_


## Calendar

> Pending

## Contact Management

> Pending

# General To do

 - [ ] Include `vader` testing
 - [ ] Write Documentation
 - [ ] Re-factor to `filetypes`

