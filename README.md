# vim-cligpt

## Description

A vim plugin that use [cligpt](https://github.com/LordPax/cligpt.git)

## Installation

```vimscript
Plug 'LordPax/vim-cligpt'
```

## Config

default configuration

```vimscript
let g:preprompt=""
let g:cligptprg="cligpt"
let g:model="gpt-3.5-turbo"
let g:temperature=0.7
```

## Usage

If no prompt is given, it will launch cligpt as chat mode.

```
:[range]Cligpt [prompt]                   Replace the selection with the result of the cligpt prompt.
:[range]CligptAdd [prompt]                Add the result of the cligpt prompt bottom the selection.
:CligptFile <file> [prompt]               Use the file as context for cligpt.
:CligptHistory                            Display the cligpt history in other window.
:CligptClearHistory                       Clear the cligpt history.
```
