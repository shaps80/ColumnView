# Column View

This framework contains a Finder-like implementation of a 'Column View' layout. heavily inspired by the Files app in iOS 13.


This repo contains 2 main class types:

- `ColumnsController`

> For an out-of-the-box solution, simply update your navigation controller class to be this type.

- `ColumnsViewController` 

> For a custom solution that's not dependany on a navigation controller, you can use this class which provides th horizontally stacked controller implementation. This is useful for example when you want to embed a navigation controller into each column.

Download the repo and run the example project to see it in action.

## Features

For a relatively simple solution, plenty of features are included nonetheless:

Familiar API
- `pushViewController`
- `popViewController`
- `popToViewController`
- `popToRootViewController`

Customizations
- Column width
- Separator thickness
- Separator color

Modern API
- Dark mode support (iOS 13)
- Catalyst support (Xcode 11)
- Size class support, automatically switches between navigation controller and horizontal layout
- Automatically updates navigationBar title and items
- Automatically updates toolbar items
- State restoration support

## Installation

The project is only 2 files so simple download the repo and copy those files into your project:

1. `ColumnsController`
2. `ColumnsViewController`

## Usage

Using the framework is extremely simple. Update your navigation controller class to be: `ColumnsController` and you're done.