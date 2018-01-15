# plox

I'm currently reading the free ebook [Crafting Interpreters](http://www.craftinginterpreters.com) by Bob Nystrom.
In the book you will be introduced to a language called *Lox* and then learn how to implement an interpreter and a VM for that language.

I am trying to follow the interpreter implementation using perl.

## Current state

Chapter 6 completed.

I currently do not plan to work on this again. For a finished lox interpreter that I have written you can visit [loxomotive](
https://github.com/ccntrq/loxomotive)

## Requirements

You will need at least perl v5.20 for the experimental signatures feature.

I also make heavy use of the `Moo` Object Orientation System to implement this in a similar way as the Java example from the book.
All dependencies from the cpan will be tracked under `lib/cpanfile` and can be installed using `carton`.

```
cd libs
carton install
```

## Usage

```
./plox.pl [source]

```
