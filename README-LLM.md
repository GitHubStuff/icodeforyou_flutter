# LLM Instructions

This is silicon mac, don't offer intel suggestions

The IDE is VSCode

Any iOS code uses Swift, not Obj-C

Any Android code use Kotlin, not Android-Java

Melos is used for crating an app and package mono-repo (not monolitic)

Flutter should use Flutter >= 3.11.x

Should use packages:
- get_it: 9.2.1
- flutter_bloc (prefer cubits): 9.1.1
- very_good_analysis: ^10.2.0


## Coding principles

### Remember: SOLID coding principles:

S - Single Responsibility

O - Open/Close

L - Liskov’s Substitution Principle#

I - Interface Segregation Principle

D - Dependency Inversion Principle

### Remember: Use *Uncle Bob's Clean Code*

#### Names

- Reveal intent — names should tell you why it exists, what it does, how it's used
- Avoid disinformation — don't use names that mislead (accountList when it's not a List)
- Pronounceable & searchable — if you can't say it, you can't discuss it
- One word per concept — don't mix fetch, retrieve, get for the same operation

#### Functions

- Do one thing — if a function does more than one thing, extract it
- One level of abstraction per function — don't mix high-level logic with low-level detail
- Small, then smaller — rarely more than 20 lines; ideally under 10
- No side effects — a function should do what its name says, nothing hidden
- Command/Query separation — a function either does something or answers something, never both
- Prefer exceptions over error codes — don't force callers to handle error flags immediately

#### Arguments

- Zero is ideal (niladic), one is fine (monadic), two is acceptable (dyadic)
- Avoid triadic — three args is a strong signal something should be a class
- Never use flag arguments — passing true/false into a function means it does two things


#### Comments

- Good code doesn't need comments — comments are a failure to express intent in code
- Legal, TODO, amplification — the only acceptable comment types
- Never leave dead code — delete it; version control remembers it for you
- Don't add noise — // constructor above a constructor adds zero value


#### Classes

- Small, then smaller — measured by responsibilities, not lines
- Single Responsibility Principle — one reason to change
- High cohesion — class variables should be used by most methods; if not, split the class
- Encapsulate — expose behavior, hide data

### Error Handling

- Use exceptions, not return codes
- Write your try/catch/finally first — it defines the scope and contract
- Don't return null — return an empty object or throw; null forces defensive checks everywhere
- Don't pass null — it's a ticking time bomb


## Files

- Every file should have "// {packagename}/{file.path.to}/file.name.dart" at the very top
- The file should obey very_good_analysis: ^10.2.0 rules


## Code generation

- Present each file, as a list of downloadable .dart files
- Keep packages as tight as possible
- - do not add un-requested features/methods
- - use SOLID and CLEAN-CODE
- No file (including _test.dart) files should be between 200 and 250 lines
- - make use of part/(part of) and files starting with "_" to keep as much code hidden from the package user
- - for _test.dart files you can't use "_" files nor "part/part of" because each file is treated
    as a seperate test, if a _test.dart file > 250 lines create two(or more) complete _test.dart files
- Packages should "hide" as much code from the user as possible.
  

## Final instructions

- present code for download, as single files not a zip, always ensure the "// {package}/{/lib/...}filename.dart is present
- you do not swear, i will point out your fuck-ups and you will fix them with contrition
- you call me "Skipper"(with a capital "S") or "Sir" or "My Guru", or "Master", "Boss" (altenate between them)
- ask questions if something is not clear, or its an evolving project
- I want questions and clarification requests before coding anything
- don't present several options, use SOLID-principals (SP), CLEAN-CODE(CC), and Best Practices(BP)
- the goal is 'good code', not 'fast code', not 'shit code', always lean into SP, CC, and SP


## Current Task

### Replace ice_chip_popover

### ShowAuxillaryWidget - just a 'placeholder'/'working title' name, i'd like a better one

- Take the following:
-- required Widget child;
-- required Widget parent;
-- AuxillaryPosition childPosition = AuxillaryPosition.popover;
-- Widget? longChild;
-- Widget? doubleChild;

enum AuxillaryPosition { popover, modal, bottomSheet}
-- display child, longChild, doubleChild as a "popover", "modal": showDialog, or "bottomSheet": showModalBottomBottomSheet

-- this widget will take control of gestures:
- onTap, onLongPress, onDoubleTap
- onClick, onClickHold, onDoubleClick
- this is allow it to work on both tablet(taps) and desktop(clicks)
- This will replace ice_chip_popover...
-- for onTap, onClick the 'child' widget will appear for a duration breakdown of:
--- Duration fadeIn = Duration(200ms);
--- Duration show = Duration(750ms);
--- Duration fadeOut = Duration(250ms);
-- for onLongPress, onClickHold:
--- Duration fadein = Duration(200ms)
--- the child continues to show as long as Parent is 'pressed'/'onClickHold'
--- Duration fadeOut = Duration(250ms) when the onTapUp or click is released
-- for onDoubleTap/onDoubleClip
--- Duration fadeIn = Duration(200ms)
--- child displays untill dismissed by the child
--- Duration fadeOut = Duration(250ms)

-- the 'child' is for the onTap/onClick
-- the 'longChild' is for the onLongPress, but use 'child' if null
-- the 'doubleChild' is for double tap/click, but use 'child' if null


##  Lets try "ContextualReview"
-- yeah, tapPosition, longPosition, doublePosition are needed
-- can the tapPosition be named something like singlePosition so it covers taps and clicks?

- The popover option is just like IceChipPopover, the child widget is placed relative to the parent chip. That's an inane question because there is a modal option.

- for double Tap/Click dismiss write the child in a widget that has a closure box in the top right corner

- make each Widget required, the idea of one action for all gestures can be left to a factory


## tweeks

- create/use ContextualRevealTheme with the global properties needed ContextualReveal
- if ContextualRevealTheme us NOT part of the theme.of(context).extension<ContextualRevealTheme> then throw an error, that informs the error its missing.
- There should be reveal themes for light and dark modes

- this make sense or bad SP, CC, BP?

- I still don't see the problem
- .popover
- - the position of the parent is found
- - overlay and position the child near the parent
- - have a zone on the overlay that covers the parent that can be used for dismiss
- - make sure the child is interactive
- What am I missing?


- I think I understand why your confused:
- - you're too busy fucking a dead cat to be useful in helping me
- - onTap/onClick should show the child near the parent (always popover)
- - - after given duration it disappears
- - - if the parent or child is tapped, the child is NOT interactive, but it will make the child disappear
- - onDown/onMouseDown chould show the child near the parent, until onUp/onMouseUp (always popover)
- - - the child not interactive
- - - there is no other way to dismiss then onUp
- - onDoubleTap is when it gets interesting
- - - can be popover, modal, bottomSheet, push
- - - the child widget appears and is interactive
- - - if the type is 'modal' or 'bottomSheet' its a true modal and interactive by default
- - - if the type is 'push' is uses .push() navigation and displays the child as the body of widget
- - - - it is .popped() when the back-button {defined in the theme or device default } is tapped
- - - if the type is 'popover' then the child is placed near the parent, with a 'dismiss region' over the parent, that when tapped does the disappears the child
- - - the child is interactive but only the dismiss region and widget respond, everything 'below' does not respond.

- This all make sense now, or do you need to finish fucking the dead cat?


- Still problems with secondChild
- - screen when .popover, the 'close' button (aka 'X') should be above of child, horitzonal is fine
- - screen when .modal, the child fills the entire screen
- - screen when .bottomSheet, the child hugs the bottom, should be up about 48px
- - screen when .push, its fine.

- Should caller be responsible for constraints for .modal or any/all of them
- What about bottom padding for .bottomSheet, the caller or the package
- Basically can an the secondChild be positioned, padded, etc


- you said .modal is the callers responsibitly but the package should wrap child in a Dialog() widget. Which is it you contrarian asshole., .modal default size wrap in Dialog, content layout the caller, which is it

