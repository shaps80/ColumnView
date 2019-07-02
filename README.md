# Column View

<img src="sample.gif" width="50%" height="50%" alt="Sample video of my column view navigation controller" />

This framework contains a Files-inspired implementation of a 'Column View' layout. Also similar to what's found in Finder on macOS.


This repo contains 2 main class types:

- `ColumnViewNavigationController`

> For an out-of-the-box solution, simply update your navigation controller class to be this type. This automatically manages your navigation controler to ensure your app behaves as expected based on the current size class.

- `ColumnViewController` 

> For a custom solution with no dependencies on navigation controller, you can use the column view directly, provides a horizontally stacked controller implementation. This is useful for example when you want to embed a navigation controller into each column.

Download the repo and run the sample project to see it in action.

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